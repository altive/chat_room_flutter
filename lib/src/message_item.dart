import 'package:flutter/material.dart';

import 'avatar_image.dart';
import 'extension.dart';
import 'inherited_altive_chat_room_theme.dart';
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
    required this.outgoingTextMessagePopupMenuLayout,
    required this.outgoingImageMessagePopupMenuLayout,
    required this.outgoingStickerMessagePopupMenuLayout,
    required this.outgoingVoiceCallMessagePopupMenuLayout,
    required this.incomingTextMessagePopupMenuLayout,
    required this.incomingImageMessagePopupMenuLayout,
    required this.incomingStickerMessagePopupMenuLayout,
    required this.incomingVoiceCallMessagePopupMenuLayout,
    required this.pendingMessageIds,
    required this.pendingIndicator,
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

  /// 送信待ち中に表示するインジケーター。
  final Widget? pendingIndicator;

  /// 送信待ち状態のメッセージ ID 一覧。
  final List<String> pendingMessageIds;

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
        pendingIndicator: pendingIndicator,
        pendingMessageIds: pendingMessageIds,
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
    required this.outgoingTextMessagePopupMenuLayout,
    required this.outgoingImageMessagePopupMenuLayout,
    required this.outgoingStickerMessagePopupMenuLayout,
    required this.outgoingVoiceCallMessagePopupMenuLayout,
    required this.incomingTextMessagePopupMenuLayout,
    required this.incomingImageMessagePopupMenuLayout,
    required this.incomingStickerMessagePopupMenuLayout,
    required this.incomingVoiceCallMessagePopupMenuLayout,
    required this.pendingIndicator,
    required this.pendingMessageIds,
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
  final PopupMenuLayout? outgoingTextMessagePopupMenuLayout;
  final PopupMenuLayout? outgoingImageMessagePopupMenuLayout;
  final PopupMenuLayout? outgoingStickerMessagePopupMenuLayout;
  final PopupMenuLayout? outgoingVoiceCallMessagePopupMenuLayout;
  final PopupMenuLayout? incomingTextMessagePopupMenuLayout;
  final PopupMenuLayout? incomingImageMessagePopupMenuLayout;
  final PopupMenuLayout? incomingStickerMessagePopupMenuLayout;
  final PopupMenuLayout? incomingVoiceCallMessagePopupMenuLayout;
  final Widget? pendingIndicator;
  final List<String> pendingMessageIds;

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
    final timeSection = isPending
        ? pendingIndicator ??
              Icon(
                Icons.timelapse,
                size: 14,
                color:
                    altiveChatRoomTheme.timeTextStyle?.color ??
                    colorScheme.onSurfaceVariant,
              )
        : _TimeText.userMessage(dateTime: message.createdAt);

    // 楽観的更新中のメッセージではポップアップメニューを表示しない。
    final popupMenuEnabled = !isPending;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: altiveChatRoomTheme.messageInsetsHorizontal,
      ),
      child: isOutgoing
          ? Column(
              children: [
                Row(
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
                        popupMenuLayoutForText:
                            outgoingTextMessagePopupMenuLayout,
                        popupMenuLayoutForImage:
                            outgoingImageMessagePopupMenuLayout,
                        popupMenuLayoutForSticker:
                            outgoingStickerMessagePopupMenuLayout,
                        popupMenuLayoutForVoiceCall:
                            outgoingVoiceCallMessagePopupMenuLayout,
                        popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
                        popupMenuEnabled: popupMenuEnabled,
                      ),
                    ),
                  ],
                ),
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
                  sizeDimension: 30,
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

/// [ChatSystemMessage]を表示するWidget。
class _SystemMessageItem extends StatelessWidget {
  const _SystemMessageItem({required this.message});

  final ChatSystemMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
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
          Text(
            message.text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onInverseSurface,
            ),
          ),
        ],
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
