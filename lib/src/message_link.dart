import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// メッセージ内で検出するリンクの種類。
enum MessageLinkKind {
  /// Web URL。
  web,

  /// メールアドレス。
  email,

  /// 電話番号。
  phone,

  /// SMS宛先。
  sms,
}

/// メッセージ内で検出したリンク。
@immutable
class MessageLink {
  /// メッセージ内で検出したリンクを作成する。
  const MessageLink({
    required this.text,
    required this.destination,
    required this.kind,
    this.hasExplicitScheme = false,
  });

  /// メッセージ内に表示する文字列。
  final String text;

  /// 外部アプリへ渡すURI。
  final Uri destination;

  /// リンクの種類。
  final MessageLinkKind kind;

  /// 元の文字列にschemeが明示されているかどうか。
  final bool hasExplicitScheme;
}

/// メッセージ本文を構成するテキストまたはリンク。
@immutable
class MessageTextSegment {
  /// リンクではないテキストを作成する。
  const MessageTextSegment.text(this.text) : link = null;

  /// リンクを作成する。
  MessageTextSegment.link(MessageLink this.link) : text = link.text;

  /// 表示する文字列。
  final String text;

  /// リンクではない場合は`null`。
  final MessageLink? link;
}

final _webPattern = RegExp(
  r'(?<![\w@])(?:https?://|www\.)'
  r'''[a-z0-9:/?#\[\]@!$&'()*+,;=%._~-]+'''
  r'|(?<![\w@])'
  r'(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+'
  '[a-z]{2,63}'
  r'''(?:[/?#][a-z0-9:/?#\[\]@!$&'()*+,;=%._~-]*)?''',
  caseSensitive: false,
);
final _emailPattern = RegExp(
  r'(?<![\w.+-])(?:mailto:)?'
  r'''[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@'''
  '[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?'
  r'(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+',
  caseSensitive: false,
);
final _phonePattern = RegExp(
  r'(?<![\w])(?:(?:tel|sms):)?\+?\d[\d ().-]{6,}\d',
  caseSensitive: false,
);
final _trailingPunctuation = RegExp(r'[。、，．,.!?！？:：;；）)］\]｝}〉》」』】]+$');

class _Candidate {
  const _Candidate(this.start, this.end, this.priority, this.link);

  final int start;
  final int end;
  final int priority;
  final MessageLink link;
}

/// URL、メールアドレス、電話番号をリンクとして抽出する。
List<MessageTextSegment> parseMessageLinks(String text) {
  if (text.isEmpty) {
    return const [];
  }

  final candidates = <_Candidate>[];
  void addMatches(
    RegExp pattern,
    int priority,
    MessageLink? Function(String) parse,
  ) {
    for (final match in pattern.allMatches(text)) {
      var matchedText = match.group(0)!;
      matchedText = matchedText.replaceFirst(_trailingPunctuation, '');
      if (matchedText.isEmpty) {
        continue;
      }
      final link = parse(matchedText);
      if (link != null) {
        final prefix = text.substring(0, match.start);
        final followsUnsupportedScheme =
            link.kind == MessageLinkKind.web &&
            !link.hasExplicitScheme &&
            RegExp(
              r'[a-z][a-z0-9+.-]*:$',
              caseSensitive: false,
            ).hasMatch(prefix);
        if (followsUnsupportedScheme) {
          continue;
        }
        candidates.add(
          _Candidate(
            match.start,
            match.start + matchedText.length,
            priority,
            link,
          ),
        );
      }
    }
  }

  // 重複時は Web URL、メール、電話番号の順で採用する。
  addMatches(_webPattern, 0, _parseWebLink);
  addMatches(_emailPattern, 1, _parseEmailLink);
  addMatches(_phonePattern, 2, _parsePhoneLink);
  candidates.sort((a, b) {
    final startComparison = a.start.compareTo(b.start);
    return startComparison != 0
        ? startComparison
        : a.priority.compareTo(b.priority);
  });

  final selected = <_Candidate>[];
  for (final candidate in candidates) {
    if (selected.any(
      (existing) =>
          candidate.start < existing.end && candidate.end > existing.start,
    )) {
      continue;
    }
    selected.add(candidate);
  }
  selected.sort((a, b) => a.start.compareTo(b.start));

  final segments = <MessageTextSegment>[];
  var offset = 0;
  for (final candidate in selected) {
    if (candidate.start > offset) {
      segments.add(
        MessageTextSegment.text(text.substring(offset, candidate.start)),
      );
    }
    segments.add(MessageTextSegment.link(candidate.link));
    offset = candidate.end;
  }
  if (offset < text.length) {
    segments.add(MessageTextSegment.text(text.substring(offset)));
  }
  return segments;
}

MessageLink? _parseWebLink(String text) {
  final destinationText = text.toLowerCase().startsWith('http')
      ? text
      : 'https://$text';
  final uri = Uri.tryParse(destinationText);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  return MessageLink(
    text: text,
    destination: uri,
    kind: MessageLinkKind.web,
    hasExplicitScheme: text.contains('://'),
  );
}

MessageLink? _parseEmailLink(String text) {
  final explicit = text.toLowerCase().startsWith('mailto:');
  final address = explicit ? text.substring('mailto:'.length) : text;
  final uri = Uri.tryParse('mailto:$address');
  if (uri == null || uri.path.isEmpty) {
    return null;
  }
  return MessageLink(
    text: text,
    destination: uri,
    kind: MessageLinkKind.email,
    hasExplicitScheme: explicit,
  );
}

MessageLink? _parsePhoneLink(String text) {
  final lowerText = text.toLowerCase();
  final isSms = lowerText.startsWith('sms:');
  final isTel = lowerText.startsWith('tel:');
  final numberText = isSms || isTel ? text.substring(4) : text;
  final digits = numberText.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 9 || digits.length > 15) {
    return null;
  }
  final normalized =
      '${numberText.trimLeft().startsWith('+') ? '+' : ''}$digits';
  final scheme = isSms ? 'sms' : 'tel';
  return MessageLink(
    text: text,
    destination: Uri(scheme: scheme, path: normalized),
    kind: isSms ? MessageLinkKind.sms : MessageLinkKind.phone,
    hasExplicitScheme: isSms || isTel,
  );
}

/// HTTP(S)リンクだけを返す。
Iterable<MessageLink> webLinksInMessage(String text) => parseMessageLinks(text)
    .map((segment) => segment.link)
    .whereType<MessageLink>()
    .where((link) => link.kind == MessageLinkKind.web);

/// メッセージ本文の先頭HTTP(S)リンクを返す。
Uri? firstWebLinkInMessage(String text) {
  for (final link in webLinksInMessage(text)) {
    return normalizeWebLinkPreviewUrl(link.destination);
  }
  return null;
}

/// resolverと保存値の比較に使うHTTP(S) URLへ正規化する。
Uri? normalizeWebLinkPreviewUrl(Uri url) {
  final scheme = url.scheme.toLowerCase();
  if ((scheme != 'http' && scheme != 'https') || url.host.isEmpty) {
    return null;
  }
  final isDefaultPort =
      (scheme == 'http' && url.port == 80) ||
      (scheme == 'https' && url.port == 443);
  return Uri(
    scheme: scheme,
    userInfo: url.userInfo,
    host: url.host.toLowerCase(),
    port: url.hasPort && !isDefaultPort ? url.port : null,
    path: url.path,
    query: url.hasQuery ? url.query : null,
  );
}

/// リンクを含む本文の [InlineSpan] を生成する。
List<InlineSpan> buildMessageLinkSpans({
  required String text,
  required TextStyle? style,
  required TextStyle? linkStyle,
  required ValueChanged<MessageLink> onOpen,
}) => [
  for (final segment in parseMessageLinks(text))
    if (segment.link case final link?)
      TextSpan(
        text: segment.text,
        style: linkStyle,
        recognizer: TapGestureRecognizer()..onTap = () => onOpen(link),
        mouseCursor: SystemMouseCursors.click,
      )
    else
      TextSpan(text: segment.text, style: style),
];

/// メッセージリンクを外部アプリで開く。
Future<void> openMessageLink(BuildContext context, MessageLink link) async {
  if (link.kind == MessageLinkKind.phone && !link.hasExplicitScheme) {
    final action = await _showPhoneActionSheet(context);
    if (action == null || !context.mounted) {
      return;
    }
    final number = link.destination.path;
    await _safeLaunch(Uri(scheme: action.scheme, path: number));
    return;
  }
  await _safeLaunch(link.destination);
}

Future<void> _safeLaunch(Uri uri) async {
  try {
    await _messageUriLauncher(uri);
  } on Object {
    // 対応アプリがない場合やプラットフォーム側で失敗した場合は何もしない。
  }
}

Future<bool> Function(Uri) _messageUriLauncher = (uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// テスト時に外部アプリ起動処理を差し替える。
@visibleForTesting
void debugSetMessageUriLauncher(Future<bool> Function(Uri)? launcher) {
  _messageUriLauncher =
      launcher ?? (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
}

enum _PhoneAction {
  call('tel'),
  sms('sms');

  const _PhoneAction(this.scheme);
  final String scheme;
}

Future<_PhoneAction?> _showPhoneActionSheet(BuildContext context) {
  final isJapanese = Localizations.localeOf(context).languageCode == 'ja';
  return showModalBottomSheet<_PhoneAction>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.call_outlined),
            title: Text(isJapanese ? '電話' : 'Call'),
            onTap: () => Navigator.pop(context, _PhoneAction.call),
          ),
          ListTile(
            leading: const Icon(Icons.sms_outlined),
            title: const Text('SMS'),
            onTap: () => Navigator.pop(context, _PhoneAction.sms),
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(isJapanese ? 'キャンセル' : 'Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
