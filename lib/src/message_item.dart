import 'package:flutter/material.dart';

import 'avatar_image.dart';
import 'extension.dart';
import 'inherited_altive_chat_room_theme.dart';
import 'model.dart';
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
    required this.myTextMessagePopupMenuLayout,
    required this.myImageMessagePopupMenuLayout,
    required this.myStickerMessagePopupMenuLayout,
    required this.myVoiceCallMessagePopupMenuLayout,
    required this.otherUserTextMessagePopupMenuLayout,
    required this.otherUserImageMessagePopupMenuLayout,
    required this.otherUserStickerMessagePopupMenuLayout,
    required this.otherUserVoiceCallMessagePopupMenuLayout,
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

  /// スタンプメッセージタップ時のコールバック。
  final ValueChanged<ChatStickerMessage>? onStickerMessageTap;

  /// テキスト内アクションボタンタップ時のコールバック。
  final ValueChanged<dynamic>? onActionButtonTap;

  /// 自分のテキストメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? myTextMessagePopupMenuLayout;

  /// 自分の画像メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? myImageMessagePopupMenuLayout;

  /// 自分のスタンプメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? myStickerMessagePopupMenuLayout;

  /// 自分の通話メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? myVoiceCallMessagePopupMenuLayout;

  /// 相手のテキストメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? otherUserTextMessagePopupMenuLayout;

  /// 相手の画像メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? otherUserImageMessagePopupMenuLayout;

  /// 相手のスタンプメッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? otherUserStickerMessagePopupMenuLayout;

  /// 相手の通話メッセージ用ポップアップメニューレイアウト。
  final PopupMenuLayout? otherUserVoiceCallMessagePopupMenuLayout;

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
        myTextMessagePopupMenuLayout: myTextMessagePopupMenuLayout,
        myImageMessagePopupMenuLayout: myImageMessagePopupMenuLayout,
        myStickerMessagePopupMenuLayout: myStickerMessagePopupMenuLayout,
        myVoiceCallMessagePopupMenuLayout: myVoiceCallMessagePopupMenuLayout,
        otherUserTextMessagePopupMenuLayout:
            otherUserTextMessagePopupMenuLayout,
        otherUserImageMessagePopupMenuLayout:
            otherUserImageMessagePopupMenuLayout,
        otherUserStickerMessagePopupMenuLayout:
            otherUserStickerMessagePopupMenuLayout,
        otherUserVoiceCallMessagePopupMenuLayout:
            otherUserVoiceCallMessagePopupMenuLayout,
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
    required this.myTextMessagePopupMenuLayout,
    required this.myImageMessagePopupMenuLayout,
    required this.myStickerMessagePopupMenuLayout,
    required this.myVoiceCallMessagePopupMenuLayout,
    required this.otherUserTextMessagePopupMenuLayout,
    required this.otherUserImageMessagePopupMenuLayout,
    required this.otherUserStickerMessagePopupMenuLayout,
    required this.otherUserVoiceCallMessagePopupMenuLayout,
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
  final ValueChanged<dynamic>? onActionButtonTap;
  final PopupMenuLayout? myTextMessagePopupMenuLayout;
  final PopupMenuLayout? myImageMessagePopupMenuLayout;
  final PopupMenuLayout? myStickerMessagePopupMenuLayout;
  final PopupMenuLayout? myVoiceCallMessagePopupMenuLayout;
  final PopupMenuLayout? otherUserTextMessagePopupMenuLayout;
  final PopupMenuLayout? otherUserImageMessagePopupMenuLayout;
  final PopupMenuLayout? otherUserStickerMessagePopupMenuLayout;
  final PopupMenuLayout? otherUserVoiceCallMessagePopupMenuLayout;
  final Widget? pendingIndicator;
  final List<String> pendingMessageIds;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSentByCurrentUser = message.isSentByCurrentUser(currentUserId);
    final isPending =
        isSentByCurrentUser && pendingMessageIds.contains(message.id);
    final bottomWidget = messageBottomWidgetBuilder?.call(
      message,
      isSentByCurrentUser: isSentByCurrentUser,
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
    final enablePopupMenu = !isPending;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: altiveChatRoomTheme.messageInsetsHorizontal,
      ),
      child: isSentByCurrentUser
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
                        textMessagePopupMenuLayout:
                            myTextMessagePopupMenuLayout,
                        imageMessagePopupMenuLayout:
                            myImageMessagePopupMenuLayout,
                        stickerMessagePopupMenuLayout:
                            myStickerMessagePopupMenuLayout,
                        voiceCallMessagePopupMenuLayout:
                            myVoiceCallMessagePopupMenuLayout,
                        popupMenuAccessoryBuilder: popupMenuAccessoryBuilder,
                        enablePopupMenu: enablePopupMenu,
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
                              textMessagePopupMenuLayout:
                                  otherUserTextMessagePopupMenuLayout,
                              imageMessagePopupMenuLayout:
                                  otherUserImageMessagePopupMenuLayout,
                              stickerMessagePopupMenuLayout:
                                  otherUserStickerMessagePopupMenuLayout,
                              voiceCallMessagePopupMenuLayout:
                                  otherUserVoiceCallMessagePopupMenuLayout,
                              popupMenuAccessoryBuilder:
                                  popupMenuAccessoryBuilder,
                              enablePopupMenu: enablePopupMenu,
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
