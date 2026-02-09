import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import 'avatar_image.dart';
import 'cached_ogp_data.dart';
import 'common_cached_network_image.dart';
import 'extension.dart';
import 'inherited_altive_chat_room_theme.dart';
import 'model.dart';
import 'no_image_widget.dart';
import 'popup_menu_overlay.dart';

/// [ChatUserMessage]を表示するWidget。
///
/// [ChatTextMessage]と[ChatImagesMessage]、[ChatStickerMessage]を表示する。
class UserMessageBubble extends StatelessWidget {
  /// インスタンスを生成する。
  const UserMessageBubble({
    super.key,
    required this.myUserId,
    required this.message,
    required this.selectableTextMessageId,
    required this.contextMenuBuilder,
    required this.onImageMessageTap,
    required this.onCollectionMessageTap,
    required this.onStickerMessageTap,
    required this.onActionButtonTap,
    required this.textMessagePopupMenuLayout,
    required this.imageMessagePopupMenuLayout,
    required this.collectionMessagePopupMenuLayout,
    required this.stickerMessagePopupMenuLayout,
    required this.voiceCallMessagePopupMenuLayout,
    required this.popupMenuAccessoryBuilder,
    this.enablePopupMenu = true,
  });

  /// ログイン中ユーザーの ID。
  final String myUserId;

  /// 表示対象のユーザーメッセージ。
  final ChatUserMessage message;

  /// テキスト選択を有効化するメッセージ ID。
  final String? selectableTextMessageId;

  /// テキスト選択時のコンテキストメニュー構築処理。
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// 画像メッセージタップ時のコールバック。
  final ImageMessageTapCallback? onImageMessageTap;

  /// コレクションメッセージタップ時のコールバック。
  final ValueChanged<ChatCollectionMessage>? onCollectionMessageTap;

  /// スタンプメッセージタップ時のコールバック。
  final ValueChanged<ChatStickerMessage>? onStickerMessageTap;

  /// テキスト内アクションボタンタップ時のコールバック。
  final ValueChanged<dynamic>? onActionButtonTap;

  /// テキストメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? textMessagePopupMenuLayout;

  /// 画像メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? imageMessagePopupMenuLayout;

  /// コレクションメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? collectionMessagePopupMenuLayout;

  /// スタンプメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? stickerMessagePopupMenuLayout;

  /// 通話メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? voiceCallMessagePopupMenuLayout;

  /// ポップアップメニュー付属領域の構築処理。
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;

  /// ポップアップメニューを有効化するかどうか。
  final bool enablePopupMenu;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.widthOf(context) * .75,
      ),
      child: switch (message) {
        ChatTextMessage() => _TextMessageBubble(
          myUserId: myUserId,
          message: message,
          canSelect: message.id == selectableTextMessageId,
          contextMenuBuilder: contextMenuBuilder,
          onActionButtonTap: onActionButtonTap,
          popupMenuLayout: textMessagePopupMenuLayout,
          popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          enablePopupMenu: enablePopupMenu,
        ),
        ChatImagesMessage() => _ImagesMessageBubble(
          myUserId: myUserId,
          message: message,
          onImageMessageTap: onImageMessageTap,
          popupMenuLayout: imageMessagePopupMenuLayout,
          popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          enablePopupMenu: enablePopupMenu,
        ),
        ChatCollectionMessage() => _ChatCollectionMessageBubble(
          myUserId: myUserId,
          message: message,
          onCollectionMessageTap: onCollectionMessageTap,
          popupMenuLayout: collectionMessagePopupMenuLayout,
          popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          enablePopupMenu: enablePopupMenu,
        ),
        ChatStickerMessage() => StickerMessageBubble(
          myUserId: myUserId,
          message: message,
          onStickerMessageTap: onStickerMessageTap,
          popupMenuLayout: stickerMessagePopupMenuLayout,
          popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          enablePopupMenu: enablePopupMenu,
        ),
        ChatVoiceCallMessage() => _VoiceCallMessageBubble(
          myUserId: myUserId,
          message: message,
          popupMenuLayout: voiceCallMessagePopupMenuLayout,
          popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          enablePopupMenu: enablePopupMenu,
        ),
      },
    );
  }
}

/// [ChatTextMessage]を表示するWidget。
class _TextMessageBubble extends StatelessWidget {
  const _TextMessageBubble({
    required this.myUserId,
    required this.message,
    required this.canSelect,
    required this.contextMenuBuilder,
    required this.onActionButtonTap,
    required this.popupMenuLayout,
    required this.popupMenuAccessoryBuilder,
    required this.enablePopupMenu,
  });

  final String myUserId;
  final ChatTextMessage message;
  final bool canSelect;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final ValueChanged<dynamic>? onActionButtonTap;
  final PopupMenuLayout? popupMenuLayout;
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;
  final bool enablePopupMenu;

  @override
  Widget build(BuildContext context) {
    final popupMenuLayout = this.popupMenuLayout;
    if (!enablePopupMenu || popupMenuLayout == null) {
      return _TextMessageBubbleContents(
        myUserId: myUserId,
        message: message,
        canSelect: canSelect,
        contextMenuBuilder: contextMenuBuilder,
        onActionButtonTap: onActionButtonTap,
      );
    }

    // ポップアップメニューを表示する為のキーを生成する。
    final widgetKey = GlobalObjectKey(context);

    final config = InheritedAltiveChatRoomTheme.of(
      context,
    ).theme.popupMenuConfig;
    // ポップアップメニューが設定されている場合、表示する為の `GestureDetector` を追加する。
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () => PopupMenuOverlay(
        layout: popupMenuLayout,
        userMessage: message,
        config: config,
        widgetKey: widgetKey,
        popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
      ).show(context: context),
      child: _TextMessageBubbleContents(
        widgetKey: widgetKey,
        myUserId: myUserId,
        message: message,
        canSelect: canSelect,
        contextMenuBuilder: contextMenuBuilder,
        onActionButtonTap: onActionButtonTap,
      ),
    );
  }
}

class _TextMessageBubbleContents extends StatelessWidget {
  const _TextMessageBubbleContents({
    this.widgetKey,
    required this.myUserId,
    required this.message,
    required this.canSelect,
    required this.contextMenuBuilder,
    required this.onActionButtonTap,
  });

  final GlobalObjectKey? widgetKey;
  final String myUserId;
  final ChatTextMessage message;
  final bool canSelect;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final ValueChanged<dynamic>? onActionButtonTap;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(10);

    final isMine = message.isMine(myUserId);

    final myMessageBoxDecoration = message.highlight
        ? altiveChatRoomTheme.myMessageHighlightBoxDecoration ??
              BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: borderRadius,
                color: theme.highlightColor,
              )
        : altiveChatRoomTheme.myMessageBoxDecoration ??
              BoxDecoration(
                borderRadius: borderRadius,
                color: theme.primaryColor,
              );
    final otherUserMessageBoxDecoration = message.highlight
        ? altiveChatRoomTheme.otherUserMessageHighlightBoxDecoration ??
              BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: borderRadius,
                color: theme.highlightColor,
              )
        : altiveChatRoomTheme.otherUserMessageBoxDecoration ??
              BoxDecoration(
                borderRadius: borderRadius,
                color: colorScheme.surfaceContainerHighest,
              );
    final decoration = isMine
        ? myMessageBoxDecoration
        : otherUserMessageBoxDecoration;

    final myMessageTextStyle = message.highlight
        ? altiveChatRoomTheme.myMessageHighlightTextStyle ??
              theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)
        : altiveChatRoomTheme.myMessageTextStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              );
    final otherUserMessageTextStyle = message.highlight
        ? altiveChatRoomTheme.otherUserHighlightMessageTextStyle ??
              theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)
        : altiveChatRoomTheme.otherUserMessageTextStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              );
    final textStyle = isMine ? myMessageTextStyle : otherUserMessageTextStyle;
    final textStyleColor = textStyle?.color;

    final myEmojiMessageTextStyle =
        altiveChatRoomTheme.myEmojiMessageTextStyle ?? textStyle;
    final otherUserEmojiMessageTextStyle =
        altiveChatRoomTheme.otherUserEmojiMessageTextStyle ?? textStyle;
    // 配色を統一するため、絵文字の配色は`textStyle`の配色を適用する。
    final emojiTextStyle =
        (isMine ? myEmojiMessageTextStyle : otherUserEmojiMessageTextStyle)
            ?.copyWith(color: textStyleColor);

    final mySpecialMessageTextStyle =
        altiveChatRoomTheme.mySpecialMessageTextStyle ?? textStyle;
    final otherUserSpecialMessageTextStyle =
        altiveChatRoomTheme.otherUserSpecialMessageTextStyle ?? textStyle;
    // 配色を統一するため、特殊文字の配色は`textStyle`の配色を適用する。
    final specialTextStyle =
        (isMine ? mySpecialMessageTextStyle : otherUserSpecialMessageTextStyle)
            ?.copyWith(color: textStyleColor);

    final linkStyle = TextStyle(
      color: colorScheme.primary,
      fontSize: 14,
      // アンダーラインを表示しない。
      decoration: TextDecoration.none,
    );
    final cursorColor =
        altiveChatRoomTheme.popupMenuConfig.backgroundColor ??
        theme.colorScheme.secondary;

    Future<void> onOpen(LinkableElement link) async {
      final url = Uri.parse(link.url);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    final messageButton = message.button;
    final hasPopupMenu = widgetKey != null;
    final replyTo = message.replyTo;

    // OGP情報を表示するためにメッセージ内のURLを抽出する。
    final urlElements = linkify(message.text).whereType<UrlElement>();

    // Linkifyを利用しInlineSpanのリストを生成する。
    final linkifyInlineSpans = buildTextSpanChildren(
      linkify(message.text),
      style: textStyle,
      linkStyle: linkStyle,
      onOpen: onOpen,
    );

    // 複数のテキストスタイルを適用する。
    final inlineSpans = _applyTextStyles(
      inlineSpans: linkifyInlineSpans,
      textStyle: textStyle,
      linkStyle: linkStyle,
      emojiTextStyle: emojiTextStyle,
      specialTextStyle: specialTextStyle,
    );

    final textSpan = TextSpan(children: inlineSpans);

    return DecoratedBox(
      key: widgetKey,
      decoration: decoration,
      // リプライ先情報と送信メッセージの区切り線である `Divider` の幅を
      // `Divider` 以外の Widget の最大幅に合わせる為に `IntrinsicWidth` を使用。
      // 使用しない場合、メッセージの長さに関わらず横幅いっぱいに `Divider` が表示される。
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyTo != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _ReplyToMessageContents(
                  replyTo: replyTo,
                  isMine: isMine,
                  isRepliedMine: replyTo.isMine(myUserId),
                  replyImageIndex: message.replyImageIndex,
                ),
              ),
              Divider(
                height: 1,
                color: isMine
                    ? altiveChatRoomTheme.myReplyToDividerColor
                    : altiveChatRoomTheme.otherUserReplyToDividerColor,
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                // OGP 情報が表示される場合でも、メッセージのテキストを左寄せにする。
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canSelect || !hasPopupMenu)
                    // 選択できるテキストかポップアップメニューが設定されていない場合、テキストは選択可能にする。
                    Theme(
                      data: theme.copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          // 選択範囲の前後に表示するカーソルの配色を変更する。
                          primary: cursorColor,
                        ),
                        textSelectionTheme: TextSelectionThemeData(
                          // カーソルの配色を変更する。
                          cursorColor: cursorColor,
                          // 選択範囲の配色を変更する。
                          selectionColor: cursorColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: SelectableText.rich(
                        textSpan,
                        autofocus: true,
                        showCursor: true,
                        contextMenuBuilder: contextMenuBuilder,
                      ),
                    )
                  else
                    Text.rich(textSpan),
                  if (messageButton != null) ...[
                    const SizedBox(height: 10),
                    // メッセージのボタンは中央寄せにする。
                    Center(
                      child: FilledButton(
                        style: altiveChatRoomTheme.messageActionButtonStyle,
                        onPressed: () =>
                            onActionButtonTap?.call(messageButton.value),
                        child: Text(messageButton.text),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  for (final e in urlElements)
                    _OgpContents(
                      urlElement: e,
                      onOpen: onOpen,
                      isMine: isMine,
                      textStyleColor: textStyleColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 指定されたスタイルに従ってテキストを分割し、適切なスタイルを適用する。
List<InlineSpan> _applyTextStyles({
  List<InlineSpan>? inlineSpans,
  TextStyle? textStyle,
  TextStyle? linkStyle,
  TextStyle? emojiTextStyle,
  TextStyle? specialTextStyle,
}) {
  if (inlineSpans == null) {
    return [];
  }

  final children = <InlineSpan>[];

  for (final span in inlineSpans) {
    // リンク以外のテキストにスタイルを適用する。
    if (span is TextSpan && span.text != null && span.style != linkStyle) {
      children.addAll(
        _processTextStyle(span, textStyle, emojiTextStyle, specialTextStyle),
      );
    } else {
      children.add(span);
    }
  }

  return children;
}

/// テキストをスタイルに従って処理する。
List<InlineSpan> _processTextStyle(
  TextSpan span,
  TextStyle? textStyle,
  TextStyle? emojiTextStyle,
  TextStyle? specialTextStyle,
) {
  final source = span.text;
  if (source == null || source.isEmpty) {
    return const <InlineSpan>[];
  }

  final children = <InlineSpan>[];
  final buffer = StringBuffer();
  TextStyle? currentStyle;

  // 文字列バッファを吐き出す。
  void flushMessageBuffer() {
    if (buffer.isEmpty) {
      return;
    }
    children.add(TextSpan(text: buffer.toString(), style: currentStyle));
    buffer.clear();
  }

  for (final character in source.characters) {
    final isEmoji = _isEmoji(character);
    final isNormalChar = _isNormalChar(character);
    TextStyle? newStyle;
    // isEmojiは一部数字や漢字にもマッチしてしまうため、isNormalCharよりも先に判定する。
    if (isNormalChar) {
      newStyle = textStyle;
    } else if (isEmoji) {
      newStyle = emojiTextStyle;
    } else {
      newStyle = specialTextStyle;
    }

    // スタイルが切り替わる境界で一度吐き出す。
    if (currentStyle != newStyle) {
      flushMessageBuffer();
      currentStyle = newStyle;
    }
    buffer.write(character);
  }

  flushMessageBuffer();
  return children;
}

/// 文字が絵文字かどうかを判定する。
/// NOTE: VS16（絵文字指定コード: U+FE0F）がついている場合は絵文字扱いする。
/// 結合用の文字（Zero Width Joiner: U+200D）を含む場合も絵文字扱いする。
bool _isEmoji(String char) {
  // 顔・物・動物などの基本的な絵文字
  // 形式: 絵文字コード +（任意）VS16 +（任意）肌色
  // e.g. 😀, 😂, 🚗, 🐶, 👍🏻, 👍🏽, 👍🏿
  if (RegExp(
    // cspell:ignore DBFF, DFFF, DFFB
    r'^[\uD83C-\uDBFF][\uDC00-\uDFFF]\uFE0F?(?:\uD83C[\uDFFB-\uDFFF])?$',
  ).hasMatch(char)) {
    return true;
  }

  // 結合用の文字を含むものは絵文字扱いする。
  // 形式: 絵文字/記号 + U+200D + 絵文字/記号
  // e.g. 🏳️‍🌈（レインボーフラッグ）, 🏳️‍⚧️（トランスジェンダーフラッグ）
  if (char.contains('\u200D')) {
    return true;
  }

  // キーキャップ（数字・#・* に枠が付くもの）
  // 形式: 「#」「*」「0〜9」+（任意）VS16 + U+20E3
  // e.g. 1️⃣, 2️⃣, #️⃣, *️⃣
  if (RegExp(r'^[#*0-9]\uFE0F?\u20E3$').hasMatch(char)) {
    return true;
  }

  // 国旗（地域コード2文字の組み合わせ）
  // e.g. 🇯🇵, 🇺🇸, 🇫🇷
  if (RegExp(
    // cspell:ignore DDFF
    r'^\uD83C[\uDDE6-\uDDFF]\uD83C[\uDDE6-\uDDFF]$',
  ).hasMatch(char)) {
    return true;
  }

  // 地域旗
  // 形式: 黒旗 + 地域タグ列 + 終端タグ
  // e.g. 🏴󠁧󠁢󠁥󠁮󠁧󠁿（イングランド）, 🏴󠁧󠁢󠁳󠁣󠁴󠁿（スコットランド）, 🏴󠁧󠁢󠁷󠁬󠁳󠁿（ウェールズ）
  if (RegExp(
    r'^\uD83C\uDFF4(?:\uDB40[\uDC60-\uDC7F]){2,}\uDB40\uDC7F$',
  ).hasMatch(char)) {
    return true;
  }

  // 矢印や記号は VS16 が付いているときだけ絵文字扱いする。
  // 形式: 記号 + VS16
  // e.g. ↔️, ☀️, ✈️, ⚠️,
  // VS16がない場合: ↔, ☀, ✈, ⚠
  if (RegExp(r'^[\u2194-\u3299]\uFE0F$').hasMatch(char)) {
    return true;
  }

  return false;
}

/// 文字が英数字または日本語かどうかを判定する。
bool _isNormalChar(String char) {
  // 正規表現の中に日本語を直接書くと警告が出るため、ignore 指定を追加する。
  // ignore: avoid_hardcoded_japanese
  final normalCharRegExp = RegExp('[a-zA-Z0-9ａ-ｚＡ-Ｚ０-９ぁ-んァ-ヶー一-龠々ｦ-ﾟ]');
  return normalCharRegExp.hasMatch(char);
}

/// OGP 情報を表示する Widget。
class _OgpContents extends StatelessWidget {
  const _OgpContents({
    required this.urlElement,
    required this.onOpen,
    required this.isMine,
    required this.textStyleColor,
  });

  final UrlElement urlElement;
  final ValueChanged<UrlElement> onOpen;
  final bool isMine;
  final Color? textStyleColor;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);

    return FutureBuilder(
      future: cachedOgpData.get(urlElement.url),
      builder: (context, snapshot) {
        final ogpTitleTextStyle =
            (isMine
                    ? altiveChatRoomTheme.myOgpTitleTextStyle ??
                          theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                    : altiveChatRoomTheme.otherUserOgpTitleTextStyle?.copyWith(
                            color: textStyleColor,
                          ) ??
                          theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ))
                ?.copyWith(color: textStyleColor);
        final ogpDescriptionTextStyle =
            (isMine
                    ? altiveChatRoomTheme.myOgpDescriptionTextStyle ??
                          theme.textTheme.labelSmall
                    : altiveChatRoomTheme.otherUserOgpDescriptionTextStyle ??
                          theme.textTheme.labelSmall)
                ?.copyWith(color: textStyleColor);
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        final ogpData = snapshot.data;
        if (ogpData == null || !ogpData.isAvailable) {
          return const SizedBox.shrink();
        }

        return Padding(
          // OGP 情報が表示されうる場合のみ間隔を指定したいため、
          // 利用側ではなくこの Widget 内で指定している。
          padding: const EdgeInsets.only(top: 8),
          child: GestureDetector(
            onTap: () => onOpen(urlElement),
            // Divider の高さを Widget の高さに合わせるために `IntrinsicHeight` を使用。
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VerticalDivider(
                    width: 2,
                    thickness: 2,
                    color: isMine
                        ? altiveChatRoomTheme.myOgpDividerColor
                        : altiveChatRoomTheme.otherUserOgpDividerColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ogpData.title != null)
                          Text(
                            ogpData.title!,
                            style: ogpTitleTextStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (ogpData.description != null)
                          Text(
                            ogpData.description!,
                            style: ogpDescriptionTextStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (ogpData.imageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      child: CommonCachedNetworkImage(
                        imageUrl: ogpData.imageUrl!,
                        width: 40,
                        height: 40,
                        errorWidget: const NoImageWidget.s(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImagesMessageBubble extends StatelessWidget {
  const _ImagesMessageBubble({
    required this.myUserId,
    required this.message,
    required this.onImageMessageTap,
    required this.popupMenuLayout,
    required this.popupMenuAccessoryBuilder,
    required this.enablePopupMenu,
  });

  final String myUserId;
  final ChatImagesMessage message;
  final ImageMessageTapCallback? onImageMessageTap;
  final PopupMenuLayout? popupMenuLayout;
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;
  final bool enablePopupMenu;

  @override
  Widget build(BuildContext context) {
    final popupMenuLayout = this.popupMenuLayout;
    final isMine = message.isMine(myUserId);
    final replyTo = message.replyTo;

    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (replyTo != null) ...[
          _ReplyToMessageBubble(
            replyTo: replyTo,
            isMine: isMine,
            isRepliedMine: replyTo.isMine(myUserId),
            replyImageIndex: message.replyImageIndex,
          ),
          const SizedBox(height: 4),
        ],
        _ImagesMessageBubbleContents(
          message: message,
          onImageMessageTap: onImageMessageTap,
          popupMenuLayout: popupMenuLayout,
          popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          enablePopupMenu: enablePopupMenu,
        ),
      ],
    );
  }
}

class _ImagesMessageBubbleContents extends StatelessWidget {
  const _ImagesMessageBubbleContents({
    required this.message,
    required this.onImageMessageTap,
    required this.popupMenuLayout,
    required this.popupMenuAccessoryBuilder,
    required this.enablePopupMenu,
  });

  /// 画像同士の間隔。
  static const spacing = 4.0;

  final ChatImagesMessage message;
  final ImageMessageTapCallback? onImageMessageTap;
  final PopupMenuLayout? popupMenuLayout;
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;
  final bool enablePopupMenu;

  @override
  Widget build(BuildContext context) {
    final imageUrls = message.imageUrls;

    void handleTap(int index) {
      onImageMessageTap?.call(imageUrls: message.imageUrls, index: index);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final tileSize = (totalWidth - spacing) / 2;

        /// 長押し時にポップアップメニューを表示するためのコールバックを生成する。
        VoidCallback? buildOnLongPress(
          BuildContext overlayContext,
          GlobalObjectKey key,
          int index,
        ) {
          final popupMenuLayout = this.popupMenuLayout;
          if (!enablePopupMenu || popupMenuLayout == null) {
            return null;
          }

          final config = InheritedAltiveChatRoomTheme.of(
            overlayContext,
          ).theme.popupMenuConfig;

          return () {
            PopupMenuOverlay(
              layout: popupMenuLayout,
              userMessage: message.copyWith(selectedImageIndex: index),
              config: config,
              widgetKey: key,
              popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
            ).show(context: overlayContext);
          };
        }

        final sectionChildren = switch (imageUrls.length) {
          // 画像が1枚のみの場合は全幅表示する。
          1 => [
            _SingleImageSection(
              message: message,
              size: totalWidth,
              onTap: handleTap,
              buildOnLongPress: buildOnLongPress,
            ),
          ],
          // 奇数枚の場合は1枚目を横長で表示し、残りをグリッド表示する。
          final length when length.isOdd => [
            _LeadingWideImageSection(
              message: message,
              width: totalWidth,
              spacing: spacing,
              onTap: handleTap,
              buildOnLongPress: buildOnLongPress,
            ),
            _ImagesGrid(
              message: message,
              imageUrls: imageUrls,
              startIndex: 1,
              roundTop: false,
              totalWidth: totalWidth,
              tileSize: tileSize,
              spacing: spacing,
              onTap: handleTap,
              buildOnLongPress: buildOnLongPress,
            ),
          ],
          // 偶数枚の場合は全てをグリッド表示する。
          final length when length.isEven => [
            _ImagesGrid(
              message: message,
              imageUrls: imageUrls,
              startIndex: 0,
              roundTop: true,
              totalWidth: totalWidth,
              tileSize: tileSize,
              spacing: spacing,
              onTap: handleTap,
              buildOnLongPress: buildOnLongPress,
            ),
          ],
          _ => null,
        };
        // 画像が1枚もない場合は何も表示しない。
        if (sectionChildren == null) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sectionChildren,
        );
      },
    );
  }
}

/// 画像の長押し時にポップアップメニューを表示するためのコールバック。
typedef PopupMenuLongPressBuilder =
    VoidCallback? Function(
      BuildContext context,
      GlobalObjectKey key,
      int index,
    );

class _SingleImageSection extends StatelessWidget {
  const _SingleImageSection({
    required this.message,
    required this.size,
    required this.onTap,
    required this.buildOnLongPress,
  });

  final ChatImagesMessage message;
  final double size;
  final ValueChanged<int> onTap;
  final PopupMenuLongPressBuilder buildOnLongPress;

  @override
  Widget build(BuildContext context) {
    const index = 0;
    final key = GlobalObjectKey('img_${message.id}_$index');
    final longPress = buildOnLongPress(context, key, index);

    return _ImageTile(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(10),
      imageUrl: message.imageUrls[index],
      onTap: () => onTap(index),
      onLongPress: longPress,
    );
  }
}

class _LeadingWideImageSection extends StatelessWidget {
  const _LeadingWideImageSection({
    required this.message,
    required this.width,
    required this.spacing,
    required this.onTap,
    required this.buildOnLongPress,
  });

  final ChatImagesMessage message;
  final double width;
  final double spacing;
  final ValueChanged<int> onTap;
  final PopupMenuLongPressBuilder buildOnLongPress;

  @override
  Widget build(BuildContext context) {
    const index = 0;
    final key = GlobalObjectKey('img_${message.id}_$index');
    final longPress = buildOnLongPress(context, key, index);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ImageTile(
          key: key,
          width: width,
          height: width * 3 / 4,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          imageUrl: message.imageUrls[index],
          onTap: () => onTap(index),
          onLongPress: longPress,
        ),
        SizedBox(height: spacing),
      ],
    );
  }
}

/// 画像をグリッド表示するWidget。
class _ImagesGrid extends StatelessWidget {
  const _ImagesGrid({
    required this.message,
    required this.imageUrls,
    required this.startIndex,
    required this.roundTop,
    required this.totalWidth,
    required this.tileSize,
    required this.spacing,
    required this.onTap,
    required this.buildOnLongPress,
  });

  final ChatImagesMessage message;
  final List<String> imageUrls;
  final int startIndex;
  final bool roundTop;
  final double totalWidth;
  final double tileSize;
  final double spacing;
  final ValueChanged<int> onTap;
  final PopupMenuLongPressBuilder buildOnLongPress;

  @override
  Widget build(BuildContext context) {
    // 表示する画像の枚数。
    final count = imageUrls.length - startIndex;
    // 2列で表示するため、行数は画像の枚数を2で割って切り上げる。
    final rows = (count / 2).ceil();

    // グリッド内の位置（行・列）に応じて角を丸め、外枠のみ丸みを付与する。
    BorderRadius borderRadiusForGrid({required int row, required int column}) {
      const radius = Radius.circular(10);
      final isFirstRow = row == 0;
      final isLastRow = row == rows - 1;
      return BorderRadius.only(
        topLeft: isFirstRow && column == 0 && roundTop ? radius : Radius.zero,
        topRight: isFirstRow && column == 1 && roundTop ? radius : Radius.zero,
        bottomLeft: isLastRow && column == 0 ? radius : Radius.zero,
        bottomRight: isLastRow && column == 1 ? radius : Radius.zero,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      // 行ごとにRowで画像を並べる。
      children: List.generate(rows, (row) {
        final leftIndex = startIndex + row * 2;
        final rightIndex = leftIndex + 1;

        assert(
          rightIndex < imageUrls.length,
          '''The first image is extracted when the count is odd, so the remaining count is always even here.''',
        );

        final leftKey = GlobalObjectKey('img_${message.id}_$leftIndex');
        final rightKey = GlobalObjectKey('img_${message.id}_$rightIndex');

        return Padding(
          padding: EdgeInsets.only(top: row == 0 ? 0 : spacing),
          child: SizedBox(
            width: totalWidth,
            child: Row(
              children: [
                _ImageTile(
                  key: leftKey,
                  width: tileSize,
                  height: tileSize,
                  borderRadius: borderRadiusForGrid(row: row, column: 0),
                  imageUrl: imageUrls[leftIndex],
                  onTap: () => onTap(leftIndex),
                  onLongPress: buildOnLongPress(context, leftKey, leftIndex),
                ),
                SizedBox(width: spacing),
                _ImageTile(
                  key: rightKey,
                  width: tileSize,
                  height: tileSize,
                  borderRadius: borderRadiusForGrid(row: row, column: 1),
                  imageUrl: imageUrls[rightIndex],
                  onTap: () => onTap(rightIndex),
                  onLongPress: buildOnLongPress(context, rightKey, rightIndex),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.imageUrl,
    required this.onTap,
    this.onLongPress,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: width,
          height: height,
          child: CommonCachedNetworkImage(imageUrl: imageUrl),
        ),
      ),
    );
  }
}

/// [ChatCollectionMessage]を表示するWidget。
class _ChatCollectionMessageBubble extends StatelessWidget {
  const _ChatCollectionMessageBubble({
    required this.myUserId,
    required this.message,
    required this.onCollectionMessageTap,
    required this.popupMenuLayout,
    required this.popupMenuAccessoryBuilder,
    required this.enablePopupMenu,
  });

  final String myUserId;
  final ChatCollectionMessage message;
  final ValueChanged<ChatCollectionMessage>? onCollectionMessageTap;
  final PopupMenuLayout? popupMenuLayout;
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;
  final bool enablePopupMenu;

  @override
  Widget build(BuildContext context) {
    final popupMenuLayout = this.popupMenuLayout;
    if (!enablePopupMenu || popupMenuLayout == null) {
      return _CollectionMessageBubbleContents(
        onCollectionMessageTap: onCollectionMessageTap,
        message: message,
      );
    }

    // ポップアップメニューを表示する為のキーを生成する。
    final widgetKey = GlobalObjectKey(context);

    final config = InheritedAltiveChatRoomTheme.of(
      context,
    ).theme.popupMenuConfig;

    final isMine = message.isMine(myUserId);
    final replyTo = message.replyTo;

    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (replyTo != null) ...[
          _ReplyToMessageBubble(
            replyTo: replyTo,
            isMine: isMine,
            isRepliedMine: replyTo.isMine(myUserId),
            replyImageIndex: message.replyImageIndex,
          ),
          const SizedBox(height: 4),
        ],
        // ポップアップメニューが設定されている場合、表示する為の `GestureDetector` を追加する。
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: () => PopupMenuOverlay(
            layout: popupMenuLayout,
            userMessage: message,
            config: config,
            widgetKey: widgetKey,
            popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          ).show(context: context),
          child: _CollectionMessageBubbleContents(
            widgetKey: widgetKey,
            onCollectionMessageTap: onCollectionMessageTap,
            message: message,
          ),
        ),
      ],
    );
  }
}

class _CollectionMessageBubbleContents extends StatelessWidget {
  const _CollectionMessageBubbleContents({
    this.widgetKey,
    required this.onCollectionMessageTap,
    required this.message,
  });

  final GlobalObjectKey? widgetKey;
  final ValueChanged<ChatCollectionMessage>? onCollectionMessageTap;
  final ChatCollectionMessage message;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final thumbnail = message.collection.thumbnailUrl;

    return GestureDetector(
      key: widgetKey,
      onTap: () => onCollectionMessageTap?.call(message),
      child: SizedBox(
        width: 206,
        child: Card(
          color: altiveChatRoomTheme.favoriteCollectionBubbleBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: thumbnail != null
                    ? CommonCachedNetworkImage(
                        imageUrl: thumbnail,
                        errorWidget: const NoImageWidget.l(),
                      )
                    : _LatestLinkOgpImage(
                        latestLinkUrl: message.collection.latestLinkUrl,
                      ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: altiveChatRoomTheme.messageInsetsHorizontal,
                  vertical: altiveChatRoomTheme.messageInsetsVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.collection.name,
                      style: altiveChatRoomTheme.favoriteContentTitleTextStyle,
                    ),
                    const SizedBox(height: 4),
                    if (message.collection.description
                        case final String description
                        when description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: altiveChatRoomTheme
                            .favoriteCollectionDetailTextStyle,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${message.collection.linkCount} links',
                      style:
                          altiveChatRoomTheme.favoriteCollectionDetailTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestLinkOgpImage extends StatelessWidget {
  const _LatestLinkOgpImage({required this.latestLinkUrl});

  final String? latestLinkUrl;

  @override
  Widget build(BuildContext context) {
    final latestLinkUrl = this.latestLinkUrl;

    if (latestLinkUrl == null) {
      return const NoImageWidget.l();
    }

    return FutureBuilder(
      future: cachedOgpData.get(latestLinkUrl),
      builder: (context, snapshot) {
        // OGPデータ取得中
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        // OGPデータが取得できなかった場合
        final ogpData = snapshot.data;
        if (ogpData == null ||
            !ogpData.isAvailable ||
            ogpData.imageUrl == null) {
          return const NoImageWidget.l();
        }

        return CommonCachedNetworkImage(
          imageUrl: ogpData.imageUrl!,
          errorWidget: const NoImageWidget.l(),
        );
      },
    );
  }
}

/// [ChatStickerMessage]を表示するWidget。
class StickerMessageBubble extends StatelessWidget {
  /// インスタンスを生成する。
  const StickerMessageBubble({
    super.key,
    required this.myUserId,
    required this.message,
    required this.onStickerMessageTap,
    required this.popupMenuLayout,
    required this.popupMenuAccessoryBuilder,
    required this.enablePopupMenu,
  });

  /// ログイン中ユーザーの ID。
  final String myUserId;

  /// 表示対象のスタンプメッセージ。
  final ChatStickerMessage message;

  /// スタンプメッセージタップ時のコールバック。
  final ValueChanged<ChatStickerMessage>? onStickerMessageTap;

  /// スタンプメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? popupMenuLayout;

  /// ポップアップメニュー付属領域の構築処理。
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;

  /// ポップアップメニューを有効化するかどうか。
  final bool enablePopupMenu;

  @override
  Widget build(BuildContext context) {
    final popupMenuLayout = this.popupMenuLayout;
    if (!enablePopupMenu || popupMenuLayout == null) {
      return _StickerMessageBubbleContents(
        onStickerMessageTap: onStickerMessageTap,
        message: message,
      );
    }

    // ポップアップメニューを表示する為のキーを生成する。
    final widgetKey = GlobalObjectKey(context);

    final config = InheritedAltiveChatRoomTheme.of(
      context,
    ).theme.popupMenuConfig;

    final isMine = message.isMine(myUserId);
    final replyTo = message.replyTo;

    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (replyTo != null) ...[
          _ReplyToMessageBubble(
            replyTo: replyTo,
            isMine: isMine,
            isRepliedMine: replyTo.isMine(myUserId),
            replyImageIndex: message.replyImageIndex,
          ),
          const SizedBox(height: 4),
        ],
        // ポップアップメニューが設定されている場合、表示する為の `GestureDetector` を追加する。
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: () => PopupMenuOverlay(
            layout: popupMenuLayout,
            userMessage: message,
            config: config,
            widgetKey: widgetKey,
            popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
          ).show(context: context),
          child: _StickerMessageBubbleContents(
            widgetKey: widgetKey,
            onStickerMessageTap: onStickerMessageTap,
            message: message,
          ),
        ),
      ],
    );
  }
}

class _StickerMessageBubbleContents extends StatelessWidget {
  const _StickerMessageBubbleContents({
    this.widgetKey,
    required this.onStickerMessageTap,
    required this.message,
  });

  final GlobalObjectKey? widgetKey;
  final ValueChanged<ChatStickerMessage>? onStickerMessageTap;
  final ChatStickerMessage message;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widgetKey,
      onTap: () => onStickerMessageTap?.call(message),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: CommonCachedNetworkImage(
          imageUrl: message.sticker.imageUrl,
          width: 180,
        ),
      ),
    );
  }
}

/// [ChatVoiceCallMessage]を表示するWidget。
class _VoiceCallMessageBubble extends StatelessWidget {
  const _VoiceCallMessageBubble({
    required this.myUserId,
    required this.message,
    required this.popupMenuLayout,
    required this.popupMenuAccessoryBuilder,
    required this.enablePopupMenu,
  });

  final String myUserId;
  final ChatVoiceCallMessage message;
  final PopupMenuLayout? popupMenuLayout;
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;
  final bool enablePopupMenu;

  @override
  Widget build(BuildContext context) {
    final popupMenuLayout = this.popupMenuLayout;
    if (!enablePopupMenu || popupMenuLayout == null) {
      return _VoiceCallMessageBubbleContents(
        myUserId: myUserId,
        message: message,
      );
    }

    // ポップアップメニューを表示する為のキーを生成する。
    final widgetKey = GlobalObjectKey(context);
    final config = InheritedAltiveChatRoomTheme.of(
      context,
    ).theme.popupMenuConfig;

    return // ポップアップメニューが設定されている場合、表示する為の `GestureDetector` を追加する。
    GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () => PopupMenuOverlay(
        layout: popupMenuLayout,
        userMessage: message,
        config: config,
        widgetKey: widgetKey,
        popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
      ).show(context: context),
      child: _VoiceCallMessageBubbleContents(
        widgetKey: widgetKey,
        myUserId: myUserId,
        message: message,
      ),
    );
  }
}

class _VoiceCallMessageBubbleContents extends StatelessWidget {
  const _VoiceCallMessageBubbleContents({
    this.widgetKey,
    required this.myUserId,
    required this.message,
  });

  final GlobalObjectKey? widgetKey;
  final String myUserId;
  final ChatVoiceCallMessage message;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderRadius = BorderRadius.circular(10);
    final myMessageBoxDecoration =
        altiveChatRoomTheme.myMessageBoxDecoration ??
        BoxDecoration(borderRadius: borderRadius, color: theme.primaryColor);
    final otherUserMessageBoxDecoration =
        altiveChatRoomTheme.otherUserMessageBoxDecoration ??
        BoxDecoration(
          borderRadius: borderRadius,
          color: colorScheme.surfaceContainerHighest,
        );

    final isMine = message.isMine(myUserId);
    final decoration = isMine
        ? myMessageBoxDecoration
        : otherUserMessageBoxDecoration;

    final myMessageTextStyle =
        altiveChatRoomTheme.myMessageTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        );
    final otherUserMessageTextStyle =
        altiveChatRoomTheme.otherUserMessageTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
    // テキストスタイルに太字を適用する。
    final textStyle = (isMine ? myMessageTextStyle : otherUserMessageTextStyle)!
        .copyWith(fontWeight: FontWeight.bold);

    final durationSeconds = message.durationSeconds;
    return Container(
      key: widgetKey,
      padding: EdgeInsets.symmetric(
        horizontal: altiveChatRoomTheme.voiceCallMessageInsetsHorizontal,
        vertical: altiveChatRoomTheme.voiceCallMessageInsetsVertical,
      ),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            foregroundColor: colorScheme.onSurfaceVariant,
            backgroundColor: colorScheme.surfaceContainerHigh.withValues(
              alpha: 0.57,
            ),
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.call),
            ),
          ),
          const SizedBox(width: 5),
          Column(
            children: [
              Text(
                message.voiceCallType.text(isMine: isMine),
                style: textStyle,
              ),
              if (durationSeconds != null)
                Text(
                  Duration(seconds: durationSeconds).hmmssText,
                  style: altiveChatRoomTheme.timeTextStyle,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// リプライ先メッセージを表示する吹き出しWidget。
/// 左下にリプライを表すアイコンが表示される。
class _ReplyToMessageBubble extends StatelessWidget {
  const _ReplyToMessageBubble({
    required this.replyTo,
    required this.isMine,
    required this.isRepliedMine,
    required this.replyImageIndex,
  });

  /// 返信先のメッセージ。
  final ChatUserMessage replyTo;

  /// 返信するメッセージが自分のものかどうか。
  final bool isMine;

  /// 返信先のメッセージが自分のものかどうか。
  final bool isRepliedMine;

  /// 複数画像の何枚目に対する返信かを示すインデックス。
  final int? replyImageIndex;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(10);

    final myMessageBoxDecoration =
        altiveChatRoomTheme.myMessageBoxDecoration ??
        BoxDecoration(borderRadius: borderRadius, color: theme.primaryColor);
    final otherUserMessageBoxDecoration =
        altiveChatRoomTheme.otherUserMessageBoxDecoration ??
        BoxDecoration(
          borderRadius: borderRadius,
          color: colorScheme.surfaceContainerHighest,
        );
    final decoration = isMine
        ? myMessageBoxDecoration
        : otherUserMessageBoxDecoration;

    return IntrinsicWidth(
      child: Column(
        children: [
          Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: DecoratedBox(
              decoration: decoration,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _ReplyToMessageContents(
                  replyTo: replyTo,
                  isMine: isMine,
                  isRepliedMine: isRepliedMine,
                  replyImageIndex: replyImageIndex,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: RotatedBox(
              quarterTurns: 2,
              child: Icon(
                Icons.reply,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// メッセージの返信先を表示するWidget。
class _ReplyToMessageContents extends StatelessWidget {
  const _ReplyToMessageContents({
    required this.replyTo,
    required this.isMine,
    required this.isRepliedMine,
    required this.replyImageIndex,
  });

  /// 返信先のメッセージ。
  final ChatUserMessage replyTo;

  /// 返信するメッセージが自分のものかどうか。
  final bool isMine;

  /// 返信先のメッセージが自分のものかどうか。
  final bool isRepliedMine;

  /// 複数画像に対する返信のインデックス。
  final int? replyImageIndex;

  /// 返信先の画像メッセージが複数画像の場合、表示するURLを解決する。
  String _resolveReplyImageUrl(List<String> imageUrls) {
    final index = replyImageIndex;
    // インデックスがnull、または範囲外の場合は先頭のURLを返す。
    if (index == null) {
      return imageUrls.first;
    }
    if (index < 0 || index >= imageUrls.length) {
      return imageUrls.first;
    }
    return imageUrls[index];
  }

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarImage(user: replyTo.sender, sizeDimension: 25),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                replyTo.sender.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isMine
                    ? altiveChatRoomTheme.myReplyToUserNameTextStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          )
                    : altiveChatRoomTheme.otherUserReplyToUserNameTextStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
              ),
              Text(
                switch (replyTo) {
                  ChatTextMessage(:final text) => text,
                  ChatImagesMessage(:final label) => label,
                  ChatCollectionMessage(:final collection) => collection.name,
                  ChatStickerMessage(:final label) => label,
                  ChatVoiceCallMessage(:final voiceCallType) =>
                    // 返信先のメッセージが自分のものかどうかで表示するテキストを変更する。
                    voiceCallType.text(isMine: isRepliedMine),
                },
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: isMine
                    ? altiveChatRoomTheme.myReplyToMessageTextStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          )
                    : altiveChatRoomTheme.otherUserReplyToMessageTextStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
              ),
            ],
          ),
        ),
        ...switch (replyTo) {
          ChatTextMessage() => [const SizedBox.shrink()],
          ChatImagesMessage(:final imageUrls) => [
            const SizedBox(width: 70),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: CommonCachedNetworkImage(
                imageUrl: _resolveReplyImageUrl(imageUrls),
                width: 39,
                height: 34,
                errorWidget: const NoImageWidget.s(),
              ),
            ),
          ],
          ChatCollectionMessage() => [const SizedBox.shrink()],
          ChatStickerMessage(:final sticker) => [
            const SizedBox(width: 70),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: CommonCachedNetworkImage(
                imageUrl: sticker.imageUrl,
                width: 39,
                height: 34,
              ),
            ),
          ],
          ChatVoiceCallMessage() => [const SizedBox.shrink()],
        },
      ],
    );
  }
}
