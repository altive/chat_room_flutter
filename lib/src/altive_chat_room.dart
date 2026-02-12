import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bottom_widget.dart';
import 'common_cached_network_image.dart';
import 'extension.dart';
import 'inherited_altive_chat_room_theme.dart';
import 'message_item.dart';
import 'model.dart';

/// {@template altive_chat_room.AltiveChatRoom}
/// チャットルームを表示するWidget。
///
/// メッセージバブルの長押しでポップアップメニューを表示する。
/// {@endtemplate}
class AltiveChatRoom extends StatefulWidget {
  /// {@macro altive_chat_room.AltiveChatRoom}
  const AltiveChatRoom({
    super.key,
    required this.theme,
    required this.myUserId,
    required this.messages,
    required this.onSendIconPressed,
    this.textEditingController,
    this.isGroupChat = false,
    this.scrollController,
    this.selectableTextMessageId,
    this.contextMenuBuilder,
    this.onRefresh,
    this.onScrollToTop,
    this.emptyWidget,
    this.hideBottomWidget = false,
    this.messageBubbleBuilder,
    this.messageBottomWidgetBuilder,
    this.popupMenuAccessoryBuilder,
    this.dateTextBuilder,
    this.onAvatarTap,
    this.onImageMessageTap,
    this.onStickerMessageTap,
    this.onActionButtonTap,
    this.sendButtonIcon,
    this.expandButtonIcon,
    this.textFieldSuffixBuilder,
    this.bottomLeadingWidgets,
    this.replyToMessageBar,
    this.stickerPackages = const [],
    this.myTextMessagePopupMenuLayout,
    this.myImageMessagePopupMenuLayout,
    this.myStickerMessagePopupMenuLayout,
    this.myVoiceCallMessagePopupMenuLayout,
    this.otherUserTextMessagePopupMenuLayout,
    this.otherUserImageMessagePopupMenuLayout,
    this.otherUserStickerMessagePopupMenuLayout,
    this.otherUserVoiceCallMessagePopupMenuLayout,
    this.pendingIndicator,
    this.pendingMessageIds = const <String>[],
  });

  /// AltiveChatRoomのテーマ。
  final AltiveChatRoomTheme theme;

  /// 自分のユーザーID。
  ///
  /// 自分自身が送信したメッセージかどうか判別するために使用する。
  final String myUserId;

  /// メッセージの配列。
  final List<ChatMessage> messages;

  /// 送信ボタンを押した時の処理。
  ///
  /// テキストメッセージを送信する際に使用する。
  /// スタンプが選択されている場合はスタンプメッセージも送信する。
  final ValueChanged<({String text, Sticker? sticker})> onSendIconPressed;

  /// グループチャットかどうか。
  final bool isGroupChat;

  /// テキストフィールドのコントローラー。
  final TextEditingController? textEditingController;

  /// スクロールコントローラー。
  final ScrollController? scrollController;

  /// 選択可能なテキストメッセージのID。
  final String? selectableTextMessageId;

  /// 選択可能なテキストメッセージで表示するコンテキストメニューをカスタマイズするビルダー。
  ///
  /// [selectableTextMessageId]と一致したテキストメッセージのみ適用される。
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// リフレッシュインジケータをドラッグした時の処理。
  final AsyncCallback? onRefresh;

  /// スクロールが一番上に到達した時の処理。
  final VoidCallback? onScrollToTop;

  /// メッセージがない場合に表示するWidget。
  final Widget? emptyWidget;

  /// ボトムのWidgetを非表示にするかどうか。
  final bool hideBottomWidget;

  /// デフォルトのメッセージバブルをカスタマイズするビルダー。
  ///
  /// Parameters:
  ///   `child` - バブル内にレンダリングされるWidget。
  ///   `message` - 表示するメッセージ。
  final Widget Function(Widget child, {required ChatMessage message})?
  messageBubbleBuilder;

  /// メッセージバブルの直下に表示するWidgetを構築するビルダー。
  final MessageBottomWidgetBuilder? messageBottomWidgetBuilder;

  /// ポップアップメニュー周辺に表示する付属Widgetを構築するビルダー。
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;

  /// デフォルトの日付表示をカスタマイズするビルダー。
  ///
  /// Parameters:
  ///   `dateText` - 日付表示用文字列（M月d日(EE)）
  ///                今日と昨日の場合以外は日付表記になる。
  ///                e.g. 今日、昨日、1月1日(日)
  final Widget Function({required String dateText})? dateTextBuilder;

  /// アバターをタップした時の処理。
  final ValueChanged<ChatUser>? onAvatarTap;

  /// 画像メッセージをタップした時の処理。
  final ImageMessageTapCallback? onImageMessageTap;

  /// スタンプメッセージをタップした時の処理。
  final ValueChanged<ChatStickerMessage>? onStickerMessageTap;

  /// メッセージのアクションボタンをタップした時の処理。
  final ValueChanged<dynamic>? onActionButtonTap;

  /// 送信ボタンのアイコン。
  final Icon? sendButtonIcon;

  /// 非表示状態の[bottomLeadingWidgets]を表示するボタンのアイコン。
  final Icon? expandButtonIcon;

  /// [TextField.decoration]の[InputDecoration.suffixIcon]に配置するWidget。
  final Widget Function(MessageInputType type)? textFieldSuffixBuilder;

  /// ボトムの先頭に配置するWidgetの配列。
  ///
  /// テキストフィールドにフォーカスがあたると非表示になる。
  /// [expandButtonIcon]をタップすることで表示できる。
  final List<Widget>? bottomLeadingWidgets;

  /// リプライ先のメッセージを表示するWidget。
  final Widget? replyToMessageBar;

  /// スタンプパッケージの配列。
  final List<StickerPackage> stickerPackages;

  /// 自分が送信したテキストメッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  ///
  /// `null`の場合はポップアップメニューが表示されず、テキストが選択可能になる。
  final PopupMenuLayout? myTextMessagePopupMenuLayout;

  /// 自分が送信した画像メッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  final PopupMenuLayout? myImageMessagePopupMenuLayout;

  /// 自分が送信したスタンプメッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  final PopupMenuLayout? myStickerMessagePopupMenuLayout;

  /// 自分が送信した音声通話メッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  final PopupMenuLayout? myVoiceCallMessagePopupMenuLayout;

  /// 自分以外が送信したテキストメッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  ///
  /// `null`の場合はポップアップメニューが表示されず、テキストが選択可能になる。
  final PopupMenuLayout? otherUserTextMessagePopupMenuLayout;

  /// 自分以外が送信した画像メッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  final PopupMenuLayout? otherUserImageMessagePopupMenuLayout;

  /// 自分以外が送信したスタンプメッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  final PopupMenuLayout? otherUserStickerMessagePopupMenuLayout;

  /// 自分以外が送信した音声通話メッセージのポップアップメニューで使用するタップ可能なアイテムの配列。
  final PopupMenuLayout? otherUserVoiceCallMessagePopupMenuLayout;

  /// 送信保留中メッセージのインジケーター。
  final Widget? pendingIndicator;

  /// 未同期メッセージのID一覧。
  final List<String> pendingMessageIds;

  @override
  State<AltiveChatRoom> createState() => _AltiveChatRoomState();
}

class _AltiveChatRoomState extends State<AltiveChatRoom> {
  // メッセージの種類を管理する。
  // TextField外をタップしたときに`MessageType.text`に切り替えるためにここで定義している。
  final messageTypeNotifier = ValueNotifier<MessageInputType>(
    MessageInputType.text,
  );

  /// 選択中のスタンプ。
  Sticker? _selectedSticker;

  @override
  void dispose() {
    messageTypeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightThemeData = ThemeData.light();
    // メッセージリストの高さを計算するために使用するキー。
    final messageListViewKey = GlobalObjectKey(context);
    final child = NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // 最上部にスクロールしたか判定する。
        if (notification.metrics.extentAfter == 0) {
          widget.onScrollToTop?.call();
          return true;
        }
        return false;
      },
      child: _MessageListView(
        key: messageListViewKey,
        myUserId: widget.myUserId,
        messages: widget.messages,
        isGroupChat: widget.isGroupChat,
        scrollController: widget.scrollController,
        selectableTextMessageId: widget.selectableTextMessageId,
        contextMenuBuilder: widget.contextMenuBuilder,
        messageBubbleBuilder: widget.messageBubbleBuilder,
        messageBottomWidgetBuilder: widget.messageBottomWidgetBuilder,
        popupMenuAccessoryBuilder: widget.popupMenuAccessoryBuilder,
        dateTextBuilder: widget.dateTextBuilder,
        messageTypeNotifier: messageTypeNotifier,
        onAvatarTap: widget.onAvatarTap,
        onImageMessageTap: widget.onImageMessageTap,
        onStickerMessageTap: widget.onStickerMessageTap,
        onActionButtonTap: widget.onActionButtonTap,
        myTextMessagePopupMenuLayout: widget.myTextMessagePopupMenuLayout,
        myImageMessagePopupMenuLayout: widget.myImageMessagePopupMenuLayout,
        myStickerMessagePopupMenuLayout: widget.myStickerMessagePopupMenuLayout,
        myVoiceCallMessagePopupMenuLayout:
            widget.myVoiceCallMessagePopupMenuLayout,
        otherUserTextMessagePopupMenuLayout:
            widget.otherUserTextMessagePopupMenuLayout,
        otherUserImageMessagePopupMenuLayout:
            widget.otherUserImageMessagePopupMenuLayout,
        otherUserStickerMessagePopupMenuLayout:
            widget.otherUserStickerMessagePopupMenuLayout,
        otherUserVoiceCallMessagePopupMenuLayout:
            widget.otherUserVoiceCallMessagePopupMenuLayout,
        pendingIndicator: widget.pendingIndicator,
        pendingMessageIds: widget.pendingMessageIds,
      ),
    );

    final onRefresh = widget.onRefresh;
    final emptyWidget = widget.emptyWidget ?? const SizedBox.shrink();
    final selectedSticker = _selectedSticker;
    return InheritedAltiveChatRoomTheme(
      theme: widget.theme,
      messageListViewKey: messageListViewKey,
      child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: widget.theme.primaryColor,
          scaffoldBackgroundColor: widget.theme.backgroundColor,
          inputDecorationTheme: widget.theme.inputDecorationTheme,
          colorScheme: lightThemeData.colorScheme.copyWith(
            primary: widget.theme.primaryColor,
            surface: widget.theme.backgroundColor,
          ),
        ),
        child: Scaffold(
          body: SafeArea(
            // bottom部分は特定のカラーを指定したいのでfalseにする。
            // trueにすると、Scaffold.backgroundColorのカラーが表示されてしまう。
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (widget.messages.isEmpty)
                        // メッセージがない場合
                        emptyWidget
                      else
                        // メッセージがある場合
                        onRefresh == null
                            ? child
                            // NOTE: ListViewを反転させている為、
                            // 上に引っ張って Pull-to-Refreshを表示させる。
                            // この際、RefreshIndicatorは使用できないので、
                            // 代わりにCustomMaterialIndicatorを使用している。
                            : CustomMaterialIndicator(
                                onRefresh: onRefresh,
                                trailingScrollIndicatorVisible: false,
                                leadingScrollIndicatorVisible: true,
                                indicatorBuilder: (_, _) =>
                                    const CircularProgressIndicator.adaptive(),
                                child: child,
                              ),
                      if (selectedSticker != null)
                        _StickerPreview(
                          backgroundColor: widget.theme.backgroundColor
                              ?.withValues(alpha: 0.5),
                          sticker: selectedSticker,
                          onSelected: (sticker) {
                            widget.onSendIconPressed.call((
                              text: '',
                              sticker: sticker,
                            ));
                            setState(() {
                              _selectedSticker = null;
                            });
                          },
                          onClosed: () {
                            setState(() {
                              _selectedSticker = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (!widget.hideBottomWidget) ...[
                  BottomWidget(
                    textEditingController: widget.textEditingController,
                    onSendIconPressed: (value) {
                      widget.onSendIconPressed(value);
                      setState(() {
                        _selectedSticker = null;
                      });
                    },
                    sendButtonIcon: widget.sendButtonIcon,
                    expandButtonIcon: widget.expandButtonIcon,
                    textFieldSuffixBuilder: widget.textFieldSuffixBuilder,
                    messageTypeNotifier: messageTypeNotifier,
                    leadingWidgets: widget.bottomLeadingWidgets,
                    replyToMessageBar: widget.replyToMessageBar,
                    stickerPackages: widget.stickerPackages,
                    selectedSticker: _selectedSticker,
                    onStickerSelected: (sticker) {
                      setState(() {
                        _selectedSticker = sticker;
                      });
                    },
                  ),
                  // SafeAreaのbottomと同じ高さで、入力エリアと同じカラーのWidgetを配置する。
                  Container(
                    height: MediaQuery.paddingOf(context).bottom,
                    color: widget.theme.inputBackgroundColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// スタンプ送信プレビュー。
class _StickerPreview extends StatelessWidget {
  const _StickerPreview({
    required this.backgroundColor,
    required this.sticker,
    required this.onSelected,
    required this.onClosed,
  });

  final Color? backgroundColor;
  final Sticker sticker;
  final ValueChanged<Sticker> onSelected;
  final VoidCallback onClosed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 138,
      width: double.infinity,
      color: backgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // スタンプ画像。
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: GestureDetector(
              onTap: () => onSelected(sticker),
              child: CommonCachedNetworkImage(imageUrl: sticker.imageUrl),
            ),
          ),

          // 閉じるボタン。
          Positioned(
            top: 12,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClosed,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageListView extends StatelessWidget {
  const _MessageListView({
    super.key,
    required this.myUserId,
    required this.messages,
    required this.isGroupChat,
    required this.scrollController,
    required this.selectableTextMessageId,
    required this.contextMenuBuilder,
    required this.messageBubbleBuilder,
    required this.messageBottomWidgetBuilder,
    required this.popupMenuAccessoryBuilder,
    required this.dateTextBuilder,
    required this.messageTypeNotifier,
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

  final String myUserId;
  final List<ChatMessage> messages;
  final bool isGroupChat;
  final ScrollController? scrollController;
  final String? selectableTextMessageId;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final Widget Function(Widget child, {required ChatMessage message})?
  messageBubbleBuilder;
  final MessageBottomWidgetBuilder? messageBottomWidgetBuilder;
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;
  final Widget Function({required String dateText})? dateTextBuilder;
  final ValueNotifier<MessageInputType> messageTypeNotifier;
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

    return GestureDetector(
      // Padding等でも反応させるために追加する。
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // キーボードを閉じるために追加する。
        FocusScope.of(context).unfocus();
        // テキストメッセージに切り替える。
        messageTypeNotifier.value = MessageInputType.text;
      },
      child: ListView.separated(
        reverse: true,
        controller: scrollController,
        itemCount: messages.length,
        separatorBuilder: (_, _) =>
            SizedBox(height: altiveChatRoomTheme.messageInsetsVertical),
        itemBuilder: (context, index) {
          final message = messages[index];

          // 同じ日付の中で先頭の要素かどうか
          final isFirstInGroup =
              index == 0 ||
              messages[index - 1].createdAt.dateText !=
                  message.createdAt.dateText;

          final messageItem = MessageItem(
            myUserId: myUserId,
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
            myVoiceCallMessagePopupMenuLayout:
                myVoiceCallMessagePopupMenuLayout,
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
          );

          final messageBubbleBuilder = this.messageBubbleBuilder;
          final dateTextBuilder = this.dateTextBuilder;
          return Column(
            children: [
              // 同じ日付の中で先頭の場合のみヘッダーを表示する
              if (isFirstInGroup) ...[
                if (dateTextBuilder == null)
                  _DateText(dateTime: message.createdAt)
                else
                  dateTextBuilder(dateText: message.createdAt.dateText),
                SizedBox(height: altiveChatRoomTheme.messageInsetsVertical),
              ],

              if (messageBubbleBuilder == null)
                messageItem
              else
                messageBubbleBuilder(messageItem, message: message),
            ],
          );
        },
      ),
    );
  }
}

/// 日付を表示するWidget。
class _DateText extends StatelessWidget {
  const _DateText({required this.dateTime});

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        dateTime.dateText,
        style: theme.textTheme.labelSmall!.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
    );
  }
}
