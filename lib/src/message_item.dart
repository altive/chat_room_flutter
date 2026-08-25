import 'dart:async';

import 'package:flutter/material.dart';

import 'avatar_image.dart';
import 'extension.dart';
import 'inherited_altive_chat_room_theme.dart';
import 'message_link.dart';
import 'models.dart';
import 'user_message_bubble.dart';

/// {@template altive_chat_room.MessageItem}
/// メッセージを表示をするWidget。
/// {@endtemplate}
class MessageItem extends StatelessWidget {
  /// {@macro altive_chat_room.MessageItem}
  const MessageItem({
    super.key,
    required this.currentUserId,
    required this.message,
    required this.isGroupChat,
    required this.selectableTextMessageId,
    required this.contextMenuBuilder,
    required this.messageBottomWidgetBuilder,
    required this.popupMenuAccessoryBuilder,
    required this.onAvatarTap,
    required this.onImageMessageTap,
    required this.onStickerMessageTap,
    required this.onActionButtonTap,
    required this.incomingAvatarSizeDimension,
    required this.outgoingTextMessagePopupMenuLayout,
    required this.outgoingImageMessagePopupMenuLayout,
    required this.outgoingStickerMessagePopupMenuLayout,
    required this.outgoingVoiceCallMessagePopupMenuLayout,
    required this.incomingTextMessagePopupMenuLayout,
    required this.incomingImageMessagePopupMenuLayout,
    required this.incomingStickerMessagePopupMenuLayout,
    required this.incomingVoiceCallMessagePopupMenuLayout,
    required this.readStatusWidget,
    required this.pendingIndicator,
    required this.pendingMessageIds,
    required this.showOutgoingMessageAppearAnimation,
    required this.outgoingMessageAnimationDuration,
    required this.outgoingMessageAnimationCurve,
    required this.outgoingMessageAnimationOffset,
  });

  /// ログイン中ユーザーの ID。
  final String currentUserId;

  /// 表示対象のメッセージ。
  final ChatMessage message;

  /// グループチャットかどうか。
  final bool isGroupChat;

  /// テキスト選択を有効化するメッセージ ID。
  final String? selectableTextMessageId;

  /// テキスト選択時のコンテキストメニュー構築処理。
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// メッセージ下部の追加ウィジェット構築処理。
  final MessageBottomWidgetBuilder? messageBottomWidgetBuilder;

  /// ポップアップメニュー付属領域の構築処理。
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;

  /// アバタータップ時のコールバック。
  final ValueChanged<ChatUser>? onAvatarTap;

  /// 画像メッセージタップ時のコールバック。
  final ImageMessageTapCallback? onImageMessageTap;

  /// ステッカーメッセージタップ時のコールバック。
  final ValueChanged<ChatStickerMessage>? onStickerMessageTap;

  /// テキスト内アクションボタンタップ時のコールバック。
  final ValueChanged<Object?>? onActionButtonTap;

  /// 受信メッセージに表示するアバター画像の直径。
  final double incomingAvatarSizeDimension;

  /// ログインユーザーのテキストメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? outgoingTextMessagePopupMenuLayout;

  /// ログインユーザーの画像メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? outgoingImageMessagePopupMenuLayout;

  /// ログインユーザーのステッカーメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? outgoingStickerMessagePopupMenuLayout;

  /// ログインユーザーの通話メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? outgoingVoiceCallMessagePopupMenuLayout;

  /// 相手のテキストメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? incomingTextMessagePopupMenuLayout;

  /// 相手の画像メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? incomingImageMessagePopupMenuLayout;

  /// 相手のステッカーメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? incomingStickerMessagePopupMenuLayout;

  /// 相手の通話メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? incomingVoiceCallMessagePopupMenuLayout;

  /// 既読表示に使用するWidget。
  final Widget? readStatusWidget;

  /// 送信待ち中に表示するインジケーター。
  final Widget? pendingIndicator;

  /// 送信待ち状態のメッセージ ID 一覧。
  final List<String> pendingMessageIds;

  /// 送信メッセージの出現アニメーションを有効にするかどうか。
  final bool showOutgoingMessageAppearAnimation;

  /// 送信メッセージの出現アニメーション時間。
  final Duration outgoingMessageAnimationDuration;

  /// 送信メッセージの出現アニメーションカーブ。
  final Curve outgoingMessageAnimationCurve;

  /// 送信メッセージの出現時の縦方向オフセット。
  final double outgoingMessageAnimationOffset;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return switch (message) {
      ChatUserMessage() => _UserMessageItem(
        currentUserId: currentUserId,
        message: message,
        isGroupChat: isGroupChat,
        selectableTextMessageId: selectableTextMessageId,
        contextMenuBuilder: contextMenuBuilder,
        messageBottomWidgetBuilder: messageBottomWidgetBuilder,
        popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
        onAvatarTap: onAvatarTap,
        onImageMessageTap: onImageMessageTap,
        onStickerMessageTap: onStickerMessageTap,
        onActionButtonTap: onActionButtonTap,
        incomingAvatarSizeDimension: incomingAvatarSizeDimension,
        outgoingTextMessagePopupMenuLayout: outgoingTextMessagePopupMenuLayout,
        outgoingImageMessagePopupMenuLayout:
            outgoingImageMessagePopupMenuLayout,
        outgoingStickerMessagePopupMenuLayout:
            outgoingStickerMessagePopupMenuLayout,
        outgoingVoiceCallMessagePopupMenuLayout:
            outgoingVoiceCallMessagePopupMenuLayout,
        incomingTextMessagePopupMenuLayout: incomingTextMessagePopupMenuLayout,
        incomingImageMessagePopupMenuLayout:
            incomingImageMessagePopupMenuLayout,
        incomingStickerMessagePopupMenuLayout:
            incomingStickerMessagePopupMenuLayout,
        incomingVoiceCallMessagePopupMenuLayout:
            incomingVoiceCallMessagePopupMenuLayout,
        readStatusWidget: readStatusWidget,
        pendingIndicator: pendingIndicator,
        pendingMessageIds: pendingMessageIds,
        showOutgoingMessageAppearAnimation: showOutgoingMessageAppearAnimation,
        outgoingMessageAnimationDuration: outgoingMessageAnimationDuration,
        outgoingMessageAnimationCurve: outgoingMessageAnimationCurve,
        outgoingMessageAnimationOffset: outgoingMessageAnimationOffset,
      ),
      ChatSystemMessage() => _SystemMessageItem(message: message),
    };
  }
}

/// [ChatUserMessage]を表示するWidget。
class _UserMessageItem extends StatelessWidget {
  const _UserMessageItem({
    required this.currentUserId,
    required this.message,
    required this.isGroupChat,
    required this.selectableTextMessageId,
    required this.contextMenuBuilder,
    required this.messageBottomWidgetBuilder,
    required this.popupMenuAccessoryBuilder,
    required this.onAvatarTap,
    required this.onImageMessageTap,
    required this.onStickerMessageTap,
    required this.onActionButtonTap,
    required this.incomingAvatarSizeDimension,
    required this.outgoingTextMessagePopupMenuLayout,
    required this.outgoingImageMessagePopupMenuLayout,
    required this.outgoingStickerMessagePopupMenuLayout,
    required this.outgoingVoiceCallMessagePopupMenuLayout,
    required this.incomingTextMessagePopupMenuLayout,
    required this.incomingImageMessagePopupMenuLayout,
    required this.incomingStickerMessagePopupMenuLayout,
    required this.incomingVoiceCallMessagePopupMenuLayout,
    required this.readStatusWidget,
    required this.pendingIndicator,
    required this.pendingMessageIds,
    required this.showOutgoingMessageAppearAnimation,
    required this.outgoingMessageAnimationDuration,
    required this.outgoingMessageAnimationCurve,
    required this.outgoingMessageAnimationOffset,
  });

  final String currentUserId;
  final ChatUserMessage message;
  final bool isGroupChat;
  final String? selectableTextMessageId;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final MessageBottomWidgetBuilder? messageBottomWidgetBuilder;
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;
  final ValueChanged<ChatUser>? onAvatarTap;
  final ImageMessageTapCallback? onImageMessageTap;
  final ValueChanged<ChatStickerMessage>? onStickerMessageTap;
  final ValueChanged<Object?>? onActionButtonTap;
  final double incomingAvatarSizeDimension;
  final PopupMenuLayout? outgoingTextMessagePopupMenuLayout;
  final PopupMenuLayout? outgoingImageMessagePopupMenuLayout;
  final PopupMenuLayout? outgoingStickerMessagePopupMenuLayout;
  final PopupMenuLayout? outgoingVoiceCallMessagePopupMenuLayout;
  final PopupMenuLayout? incomingTextMessagePopupMenuLayout;
  final PopupMenuLayout? incomingImageMessagePopupMenuLayout;
  final PopupMenuLayout? incomingStickerMessagePopupMenuLayout;
  final PopupMenuLayout? incomingVoiceCallMessagePopupMenuLayout;
  final Widget? readStatusWidget;
  final Widget? pendingIndicator;
  final List<String> pendingMessageIds;
  final bool showOutgoingMessageAppearAnimation;
  final Duration outgoingMessageAnimationDuration;
  final Curve outgoingMessageAnimationCurve;
  final double outgoingMessageAnimationOffset;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOutgoing = message.isOutgoing(currentUserId: currentUserId);
    final isPending = isOutgoing && pendingMessageIds.contains(message.id);
    final bottomWidget = messageBottomWidgetBuilder?.call(
      message,
      isOutgoing: isOutgoing,
    );
    final timeSection = _BubbleSideStatus(
      dateTime: message.createdAt,
      isRead: isOutgoing && message.isRead,
      readStatusWidget: readStatusWidget,
      pendingIndicator: isPending
          ? pendingIndicator ??
                Icon(
                  Icons.timelapse,
                  size: 14,
                  color:
                      altiveChatRoomTheme.timeTextStyle?.color ??
                      colorScheme.onSurfaceVariant,
                )
          : null,
    );

    // 楽観的更新中のメッセージではポップアップメニューを表示しない。
    final popupMenuEnabled = !isPending;
    final outgoingRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        timeSection,
        const SizedBox(width: 6),
        Flexible(
          child: UserMessageBubble(
            currentUserId: currentUserId,
            message: message,
            selectableTextMessageId: selectableTextMessageId,
            contextMenuBuilder: contextMenuBuilder,
            onImageMessageTap: onImageMessageTap,
            onStickerMessageTap: onStickerMessageTap,
            onActionButtonTap: onActionButtonTap,
            popupMenuLayoutForText: outgoingTextMessagePopupMenuLayout,
            popupMenuLayoutForImage: outgoingImageMessagePopupMenuLayout,
            popupMenuLayoutForSticker: outgoingStickerMessagePopupMenuLayout,
            popupMenuLayoutForVoiceCall:
                outgoingVoiceCallMessagePopupMenuLayout,
            popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
            popupMenuEnabled: popupMenuEnabled,
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: altiveChatRoomTheme.messageInsetsHorizontal,
        vertical: altiveChatRoomTheme.messageInsetsVertical,
      ),
      child: isOutgoing
          ? Column(
              children: [
                if (showOutgoingMessageAppearAnimation)
                  _AnimatableOutgoingBubble(
                    duration: outgoingMessageAnimationDuration,
                    curve: outgoingMessageAnimationCurve,
                    initialVerticalOffset: outgoingMessageAnimationOffset,
                    child: outgoingRow,
                  )
                else
                  outgoingRow,
                if (bottomWidget != null) ...[
                  const SizedBox(height: 4),
                  bottomWidget,
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarImage(
                  user: message.sender,
                  sizeDimension: incomingAvatarSizeDimension,
                  onAvatarTap: onAvatarTap,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // グループチャットの場合は送信者名を表示する。
                      if (isGroupChat) ...[
                        Text(
                          message.sender.name,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: UserMessageBubble(
                              currentUserId: currentUserId,
                              message: message,
                              selectableTextMessageId: selectableTextMessageId,
                              contextMenuBuilder: contextMenuBuilder,
                              onImageMessageTap: onImageMessageTap,
                              onStickerMessageTap: onStickerMessageTap,
                              onActionButtonTap: onActionButtonTap,
                              popupMenuLayoutForText:
                                  incomingTextMessagePopupMenuLayout,
                              popupMenuLayoutForImage:
                                  incomingImageMessagePopupMenuLayout,
                              popupMenuLayoutForSticker:
                                  incomingStickerMessagePopupMenuLayout,
                              popupMenuLayoutForVoiceCall:
                                  incomingVoiceCallMessagePopupMenuLayout,
                              popupMenuAccessoryBuilder:
                                  popupMenuAccessoryBuilder,
                              popupMenuEnabled: popupMenuEnabled,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _TimeText.userMessage(dateTime: message.createdAt),
                        ],
                      ),
                      if (bottomWidget != null) ...[
                        const SizedBox(height: 4),
                        bottomWidget,
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// 送信直後に出現アニメーションを適用したメッセージバブル。
class _AnimatableOutgoingBubble extends StatelessWidget {
  const _AnimatableOutgoingBubble({
    required this.duration,
    required this.curve,
    required this.initialVerticalOffset,
    required this.child,
  });

  final Duration duration;
  final Curve curve;
  final double initialVerticalOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        final opacity = value.clamp(0, 1).toDouble();
        final translateY = (1 - value) * initialVerticalOffset;
        final scale = 0.96 + (value * 0.04);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              alignment: Alignment.bottomRight,
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// [ChatSystemMessage]を表示するWidget。
class _SystemMessageItem extends StatelessWidget {
  const _SystemMessageItem({required this.message});

  final ChatSystemMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.widthOf(context) * .75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _TimeText.systemMessage(dateTime: message.createdAt),
            Text.rich(
              TextSpan(
                children: buildMessageLinkSpans(
                  text: message.text,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onInverseSurface,
                  ),
                  linkStyle: theme.textTheme.bodyMedium!.copyWith(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  onOpen: (link) => unawaited(openMessageLink(context, link)),
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 時間を表示するWidget。
class _TimeText extends StatelessWidget {
  const _TimeText.userMessage({required this.dateTime}) : isSystem = false;

  const _TimeText.systemMessage({required this.dateTime}) : isSystem = true;

  final DateTime dateTime;
  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);
    final color = isSystem ? theme.colorScheme.onInverseSurface : null;
    return Text(
      dateTime.timeText,
      style:
          altiveChatRoomTheme.timeTextStyle?.copyWith(color: color) ??
          theme.textTheme.labelSmall!.copyWith(color: color),
    );
  }
}

class _BubbleSideStatus extends StatelessWidget {
  const _BubbleSideStatus({
    required this.dateTime,
    required this.isRead,
    this.readStatusWidget,
    this.pendingIndicator,
  });

  final DateTime dateTime;
  final bool isRead;
  final Widget? readStatusWidget;
  final Widget? pendingIndicator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final readTextStyle =
        altiveChatRoomTheme.timeTextStyle?.copyWith(
          color: theme.colorScheme.primary,
        ) ??
        theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.primary);
    final timeTextStyle =
        altiveChatRoomTheme.timeTextStyle ?? theme.textTheme.labelSmall!;
    final readStatus = isRead
        ? readStatusWidget ??
              // 既定表示として日本語の「既読」を表示する。
              // ignore: altive_lints/avoid_hardcoded_japanese
              Text('既読', style: readTextStyle)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ?readStatus,
        ?pendingIndicator,
        Text(dateTime.timeText, style: timeTextStyle),
      ],
    );
  }
}
