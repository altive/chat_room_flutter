import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:altive_chat_room/src/message_link.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('リンクプレビューfixture', () {
    final fixture =
        jsonDecode(
              File(
                'contract/fixtures/link-preview-cases.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    final selectionCases = fixture['selectionCases']! as List<Object?>;

    for (final value in selectionCases) {
      final testCase = value! as Map<String, Object?>;
      test(testCase['name']! as String, () {
        expect(
          firstWebLinkInMessage(testCase['text']! as String)?.toString(),
          testCase['sourceUrl'],
        );
      });
    }
  });

  test('表示モデルはHTTP(S)・タイトル・文字数を検証する', () {
    expect(_preview('表示可能').isDisplayable, isTrue);
    expect(
      ChatLinkPreview(
        sourceUrl: Uri.parse('file:///private/data'),
        title: '非表示',
      ).isDisplayable,
      isFalse,
    );
    expect(
      ChatLinkPreview(
        sourceUrl: Uri.parse('https://example.com'),
        title: '',
      ).isDisplayable,
      isFalse,
    );
    expect(
      ChatLinkPreview(
        sourceUrl: Uri.parse('https://example.com'),
        title: 'a' * 201,
      ).isDisplayable,
      isFalse,
    );
  });

  testWidgets('送信済みカードと本文リンクが同じURLを通知する', (tester) async {
    await initializeDateFormatting('en');
    final tappedUrls = <Uri>[];
    final preview = ChatLinkPreview(
      sourceUrl: Uri.parse('https://example.com/article'),
      title: '記事タイトル',
      description: '記事の説明',
      siteName: 'Example',
      image: const ChatLinkPreviewImage(
        resource: 'preview/example.webp',
        pixelWidth: 1200,
        pixelHeight: 630,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AltiveChatRoom(
          theme: const AltiveChatRoomTheme(),
          currentUserId: 'me',
          messages: [
            ChatTextMessage(
              id: 'message',
              createdAt: DateTime(2026),
              sender: _user,
              text: 'https://example.com/article',
              linkPreview: preview,
            ),
          ],
          onSendIconPressed: (_) {},
          onWebLinkTap: tappedUrls.add,
          linkPreviewImageBuilder: (_, image) => ColoredBox(
            key: ValueKey(image.resource),
            color: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.text('記事タイトル'), findsOneWidget);
    expect(find.byKey(const ValueKey('preview/example.webp')), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byType(ChatLinkPreviewCard))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    await tester.tap(find.byType(ChatLinkPreviewCard));
    await tester.pump();
    expect(tappedUrls, [preview.sourceUrl]);

    _linkRecognizers(tester)['https://example.com/article']!.onTap!.call();
    await tester.pump();
    expect(tappedUrls, [preview.sourceUrl, preview.sourceUrl]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('500ms後に先頭URLだけを解決し同じURLでは再取得しない', (tester) async {
    final resolvedUrls = <Uri>[];
    await _pumpComposer(
      tester,
      resolver: (url) async {
        resolvedUrls.add(url);
        return _preview('解決済み', sourceUrl: url);
      },
    );

    await tester.enterText(
      find.byType(TextField),
      'https://first.example https://second.example',
    );
    await tester.pump(const Duration(milliseconds: 499));
    expect(resolvedUrls, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(resolvedUrls.map((url) => url.toString()), [
      'https://first.example',
    ]);
    expect(find.text('解決済み'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      '説明 https://first.example を追記',
    );
    await tester.pump(const Duration(seconds: 1));
    expect(resolvedUrls, hasLength(1));
  });

  testWidgets('URL変更前の遅い結果を破棄する', (tester) async {
    final first = Completer<ChatLinkPreview?>();
    final second = Completer<ChatLinkPreview?>();
    await _pumpComposer(
      tester,
      resolver: (url) =>
          url.host == 'first.example' ? first.future : second.future,
    );

    await tester.enterText(find.byType(TextField), 'https://first.example');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField), 'https://second.example');
    await tester.pump(const Duration(milliseconds: 500));
    first.complete(
      _preview('古い結果', sourceUrl: Uri.parse('https://first.example')),
    );
    await tester.pump();
    expect(find.text('古い結果'), findsNothing);
    second.complete(
      _preview('新しい結果', sourceUrl: Uri.parse('https://second.example')),
    );
    await tester.pump();
    expect(find.text('新しい結果'), findsOneWidget);
  });

  testWidgets('resolver失敗や処理中でも送信を待たない', (tester) async {
    ChatComposerSubmission? submission;
    final unresolved = Completer<ChatLinkPreview?>();
    var legacyCount = 0;
    await _pumpComposer(
      tester,
      resolver: (_) => unresolved.future,
      onLegacySend: (_) => legacyCount += 1,
      onSubmit: (value) => submission = value,
    );

    await tester.enterText(find.byType(TextField), ' https://example.com ');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(submission?.text, 'https://example.com');
    expect(submission?.linkPreview, isNull);
    expect(legacyCount, 0);
    expect(find.text('https://example.com'), findsNothing);
  });

  testWidgets('解決済みpreviewを型付きsubmissionへ含める', (tester) async {
    ChatComposerSubmission? submission;
    await _pumpComposer(
      tester,
      resolver: (url) async => _preview('送信対象', sourceUrl: url),
      onSubmit: (value) => submission = value,
    );

    await tester.enterText(find.byType(TextField), 'https://example.com');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(submission?.linkPreview?.title, '送信対象');
  });
}

ChatLinkPreview _preview(String title, {Uri? sourceUrl}) => ChatLinkPreview(
  sourceUrl: sourceUrl ?? Uri.parse('https://example.com'),
  title: title,
);

const _user = ChatUser(
  id: 'me',
  name: '自分',
  avatarImageUrl: 'https://example.com/avatar.png',
);

Future<void> _pumpComposer(
  WidgetTester tester, {
  required ChatLinkPreviewResolver resolver,
  ValueChanged<({String text, Sticker? sticker})>? onLegacySend,
  ValueChanged<ChatComposerSubmission>? onSubmit,
}) => tester.pumpWidget(
  MaterialApp(
    home: AltiveChatRoom(
      theme: const AltiveChatRoomTheme(),
      currentUserId: 'me',
      messages: const [],
      showSendButtonInTextField: true,
      onSendIconPressed: onLegacySend ?? (_) {},
      onSubmit: onSubmit,
      linkPreviewResolver: resolver,
    ),
  ),
);

Map<String, TapGestureRecognizer> _linkRecognizers(WidgetTester tester) {
  final links = <String, TapGestureRecognizer>{};

  void visitSpan(InlineSpan span) {
    if (span case TextSpan(:final text, :final recognizer)) {
      if (text != null && recognizer is TapGestureRecognizer) {
        links[text] = recognizer;
      }
      span.children?.forEach(visitSpan);
    }
  }

  for (final widget in tester.allWidgets) {
    switch (widget) {
      case Text(:final textSpan?):
        visitSpan(textSpan);
      case SelectableText(:final textSpan?):
        visitSpan(textSpan);
    }
  }
  return links;
}
