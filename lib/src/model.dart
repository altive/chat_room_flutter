import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'altive_chat_room.dart';

/// [AltiveChatRoom]のテーマ。
///
/// [ThemeData.light]をベースに上書きして使用する。
@immutable
class AltiveChatRoomTheme {
  /// インスタンスを生成する。
  const AltiveChatRoomTheme({
    this.primaryColor,
    this.backgroundColor,
    this.messageInsetsHorizontal = 16,
    this.messageInsetsVertical = 10,
    this.voiceCallMessageInsetsHorizontal = 12,
    this.voiceCallMessageInsetsVertical = 14,
    this.myMessageBoxDecoration,
    this.myMessageHighlightBoxDecoration,
    this.otherUserMessageBoxDecoration,
    this.otherUserMessageHighlightBoxDecoration,
    this.myMessageTextStyle,
    this.myMessageHighlightTextStyle,
    this.myEmojiMessageTextStyle,
    this.mySpecialMessageTextStyle,
    this.otherUserMessageTextStyle,
    this.otherUserHighlightMessageTextStyle,
    this.otherUserEmojiMessageTextStyle,
    this.otherUserSpecialMessageTextStyle,
    this.myReplyToMessageTextStyle,
    this.myReplyToUserNameTextStyle,
    this.myReplyToDividerColor,
    this.otherUserReplyToMessageTextStyle,
    this.otherUserReplyToUserNameTextStyle,
    this.otherUserReplyToDividerColor,
    this.myOgpTitleTextStyle,
    this.myOgpDescriptionTextStyle,
    this.myOgpDividerColor,
    this.otherUserOgpTitleTextStyle,
    this.otherUserOgpDescriptionTextStyle,
    this.otherUserOgpDividerColor,
    this.favoriteContentTitleTextStyle,
    this.favoriteCollectionDetailTextStyle,
    this.favoriteCollectionBubbleBackgroundColor,
    this.favoriteCollectionNoImageBackgroundColor,
    this.favoriteCollectionNoImageTextStyle,
    this.timeTextStyle,
    this.messageActionButtonStyle,
    this.inputDecorationTheme,
    this.inputBackgroundColor,
    this.popupMenuConfig = const PopupMenuConfig(),
  });

  /// プライマリカラー。
  ///
  /// メッセージバブルの背景色などに使用する。
  final Color? primaryColor;

  /// 背景色。
  final Color? backgroundColor;

  /// メッセージバブルの水平方向の余白。
  final double messageInsetsHorizontal;

  /// メッセージバブルの垂直方向の余白。
  final double messageInsetsVertical;

  /// 音声通話メッセージバブルの水平方向の余白。
  final double voiceCallMessageInsetsHorizontal;

  /// 音声通話メッセージバブルの垂直方向の余白。
  final double voiceCallMessageInsetsVertical;

  /// 自分が送信したメッセージバブルの装飾。
  ///
  /// `null`の場合は、背景色に[ThemeData.primaryColor]が使用される。
  final BoxDecoration? myMessageBoxDecoration;

  /// 自分が送信したメッセージバブルのハイライトされた場合の装飾。
  ///
  /// `null`の場合は、背景色に[ThemeData.highlightColor]を使用し枠線に`Colors.grey[700]`が使用される。
  final BoxDecoration? myMessageHighlightBoxDecoration;

  /// 自分以外が送信したメッセージバブルの装飾。
  ///
  /// `null`の場合は、背景色に`Colors.grey[200]`が使用される。
  final BoxDecoration? otherUserMessageBoxDecoration;

  /// 自分以外が送信したメッセージバブルのハイライトされた場合の装飾。
  ///
  /// `null`の場合は、背景色に[ThemeData.highlightColor]を使用し枠線に`Colors.grey[700]`が使用される。
  final BoxDecoration? otherUserMessageHighlightBoxDecoration;

  /// 自分が送信したテキストメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を[ColorScheme.onPrimary]で上書きしたものが使用される。
  final TextStyle? myMessageTextStyle;

  /// 自分が送信したテキストメッセージのハイライトされた場合のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[700]`で上書きしたものが使用される。
  final TextStyle? myMessageHighlightTextStyle;

  /// 自分が送信した絵文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[myMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? myEmojiMessageTextStyle;

  /// 自分が送信した英数字日本語以外の特殊文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[myMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? mySpecialMessageTextStyle;

  /// 自分以外が送信したテキストメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[600]`で上書きしたものが使用される。
  final TextStyle? otherUserMessageTextStyle;

  /// 自分以外が送信したテキストメッセージのハイライトされた場合のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[700]`で上書きしたものが使用される。
  final TextStyle? otherUserHighlightMessageTextStyle;

  /// 自分以外が送信した絵文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[otherUserMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserEmojiMessageTextStyle;

  /// 自分以外が送信した英数字日本語以外の特殊文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[otherUserMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserSpecialMessageTextStyle;

  /// 自分が送信したメッセージに対するリプライ先のメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を[ColorScheme.onPrimary]で上書きしたものが使用される。
  final TextStyle? myReplyToMessageTextStyle;

  /// 自分が送信したメッセージに対するリプライ先のユーザー名のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を[ColorScheme.onPrimary]で上書きしたものが使用される。
  final TextStyle? myReplyToUserNameTextStyle;

  /// 自分が送信したメッセージに対するリプライ先の仕切り線の色。
  ///
  /// リプライ先に対してテキストメッセージを送信する場合のみ使用される。
  final Color? myReplyToDividerColor;

  /// 自分以外が送信したメッセージに対するリプライ先のメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[600]`で上書きしたものが使用される。
  final TextStyle? otherUserReplyToMessageTextStyle;

  /// 自分以外が送信したメッセージに対するリプライ先のユーザー名のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[600]`で上書きしたものが使用される。
  final TextStyle? otherUserReplyToUserNameTextStyle;

  /// 自分以外が送信したメッセージに対するリプライ先の仕切り線の色。
  ///
  /// リプライ先に対してテキストメッセージを送信する場合のみ使用される。
  final Color? otherUserReplyToDividerColor;

  /// 自分が送信したメッセージの OGP タイトルのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodySmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? myOgpTitleTextStyle;

  /// 自分が送信したメッセージの OGP 説明のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? myOgpDescriptionTextStyle;

  /// 自分が送信したメッセージの OGP 情報の仕切り線の色。
  ///
  /// OGP 情報が表示される場合のみ使用される。
  final Color? myOgpDividerColor;

  /// 自分以外が送信したメッセージの OGP タイトルのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodySmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserOgpTitleTextStyle;

  /// 自分以外が送信したメッセージの OGP 説明のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserOgpDescriptionTextStyle;

  /// 自分以外が送信したメッセージの OGP 情報の仕切り線の色。
  ///
  /// OGP 情報が表示される場合のみ使用される。
  final Color? otherUserOgpDividerColor;

  /// お気に入りコンテンツのタイトルのテキストスタイル。
  ///
  /// お気に入りコレクション名やお気に入りリンクのタイトルに使用される。
  final TextStyle? favoriteContentTitleTextStyle;

  /// お気にコレクションの詳細情報のテキストスタイル。
  ///
  /// お気に入りコレクションの説明やリンク数の表示に使用される。
  final TextStyle? favoriteCollectionDetailTextStyle;

  /// お気に入りコレクションのカードの背景色。
  final Color? favoriteCollectionBubbleBackgroundColor;

  /// お気に入りコレクションの画像がない場合に表示するWidgetの背景色。
  final Color? favoriteCollectionNoImageBackgroundColor;

  /// お気に入りコレクションの画像がない場合に表示するWidgetのテキストスタイル。
  final TextStyle? favoriteCollectionNoImageTextStyle;

  /// 時間を表示するテキストのテキストスタイル。
  ///
  /// - [ChatUserMessage]の場合は左右どちらかに表示される。
  ///   - `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用する。
  /// - [ChatSystemMessage]の場合はメッセージバブル内の上部に表示される。
  ///   - `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し、
  ///   - 配色は`Colors.white`で上書きしたものが使用される。
  final TextStyle? timeTextStyle;

  /// メッセージ下部に表示する[MessageActionButton]のボタンスタイル。
  ///
  /// [FilledButton]に適用するスタイル。
  final ButtonStyle? messageActionButtonStyle;

  /// テキストフィールドの装飾。
  final InputDecorationTheme? inputDecorationTheme;

  /// テキストフィールドを表示するボトムの背景色。
  final Color? inputBackgroundColor;

  /// ポップアップメニューの設定
  final PopupMenuConfig popupMenuConfig;
}

/// メッセージバブル直下に表示するWidgetを構築するビルダーの型定義。
typedef MessageBottomWidgetBuilder =
    Widget? Function(ChatUserMessage message, {required bool isMine});

/// ポップアップメニュー周辺の付属Widgetを構築するビルダーの型定義。
/// [PreferredSizeWidget]を利用し、オーバーレイの幅・高さを安定して算出する。
typedef PopupMenuAccessoryBuilder =
    PreferredSizeWidget? Function(
      ChatUserMessage message, {

      /// ポップアップメニューを閉じたいときに呼び出すコールバック。
      required VoidCallback closePopupMenu,
    });

/// ポップアップメニューの設定。
@immutable
class PopupMenuConfig {
  /// インスタンスを生成する。
  const PopupMenuConfig({
    this.itemWidth = 72,
    this.itemHeight = 65,
    this.arrowHeight = 12,
    this.buttonItemTextStyle,
    this.backgroundColor,
    this.highlightColor,
    this.dividerColor,
  });

  /// メニューアイテムの幅。
  final double itemWidth;

  /// メニューアイテムの高さ。
  final double itemHeight;

  /// 矢印の高さ。
  final double arrowHeight;

  /// [PopupMenuButtonItem.title]のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し
  /// 配色を[ColorScheme.onSecondary]で上書きしたものが使用される。
  final TextStyle? buttonItemTextStyle;

  /// 背景色。
  ///
  /// `null`の場合は、[ColorScheme.secondary]が使用される。
  final Color? backgroundColor;

  /// タップした際のハイライト色。
  ///
  /// `null`の場合は、`Colors.grey[400]`が使用される。
  final Color? highlightColor;

  /// 仕切りの色。
  ///
  /// `null`の場合は、[ColorScheme.onPrimary]が使用される。
  final Color? dividerColor;
}

@immutable
/// ChatMessage を表すクラス。
sealed class ChatMessage {
  const ChatMessage({required this.id, required this.createdAt});

  /// メッセージID。
  final String id;

  /// 作成日時。
  final DateTime createdAt;
}

/// ユーザーが送信するメッセージ。
@immutable
sealed class ChatUserMessage implements ChatMessage {
  const ChatUserMessage({
    required this.id,
    required this.createdAt,
    required this.sender,
    this.unsent = false,
    this.replyTo,
    this.replyImageIndex,
    required this.label,
  });

  /// メッセージID。
  @override
  final String id;

  /// 作成日時。
  @override
  final DateTime createdAt;

  /// 送信者。
  final ChatUser sender;

  /// 送信が取り消されたかどうか。
  final bool unsent;

  /// リプライ先メッセージ。
  final ChatUserMessage? replyTo;

  /// 画像メッセージへの返信だった場合にどの画像に対する返信かを示すインデックス。
  /// 画像への返信でなければNull。
  final int? replyImageIndex;

  /// ラベル。
  ///
  /// リプライ先のメッセージの種類の表示に使用する。
  final String label;

  /// 自分自身が送信したメッセージかどうか。
  bool isMine(String myUserId) {
    return sender.id == myUserId;
  }
}

/// テキストメッセージ。
@immutable
class ChatTextMessage extends ChatUserMessage {
  /// インスタンスを生成する。
  const ChatTextMessage({
    required super.id,
    required super.createdAt,
    required super.sender,
    required this.text,
    this.highlight = false,
    this.button,
    super.replyTo,
    super.replyImageIndex,
    super.label = 'Text',
  });

  /// テキスト。
  ///
  /// テキストメッセージ内のURLはタップ可能。
  final String text;

  /// メッセージをハイライト表示するかどうか。
  final bool highlight;

  /// 下部に表示するボタン。
  ///
  /// ボタン付きのメッセージは表示可能だが、作成して送信することはできない。
  final MessageActionButton? button;

  /// 値を置き換えた新しい [ChatTextMessage] を返する。
  ChatTextMessage copyWith({
    String? id,
    DateTime? createdAt,
    ChatUser? sender,
    String? text,
    bool? highlight,
    MessageActionButton? button,
    ChatTextMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatTextMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      highlight: highlight ?? this.highlight,
      button: button ?? this.button,
      replyTo: replyTo ?? this.replyTo,
      replyImageIndex: replyImageIndex ?? this.replyImageIndex,
      label: label ?? this.label,
    );
  }

  @override
  String toString() =>
      'ChatTextMessage('
      'id: $id, '
      'createdAt: $createdAt, '
      'sender: $sender, '
      'text: $text, '
      'highlight: $highlight, '
      'button: $button, '
      'replyTo: $replyTo, '
      'replyImageIndex: $replyImageIndex, '
      'label: $label'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatTextMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.highlight, highlight) ||
                other.highlight == highlight) &&
            (identical(other.button, button) || other.button == button) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo) &&
            (identical(other.replyImageIndex, replyImageIndex) ||
                other.replyImageIndex == replyImageIndex) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    sender,
    text,
    highlight,
    button,
    replyTo,
    replyImageIndex,
    label,
  ]);
}

/// メッセージ下部に表示するボタン。
@immutable
class MessageActionButton {
  /// インスタンスを生成する。
  const MessageActionButton({required this.text, required this.value});

  /// ボタンに表示するテキスト。
  final String text;

  /// ボタンがタップされた際に送信される値。
  final dynamic value;

  @override
  String toString() =>
      'MessageActionButton('
      'text: $text, '
      'value: $value'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MessageActionButton &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hashAll([text, value]);
}

/// 複数画像メッセージ。
@immutable
class ChatImagesMessage extends ChatUserMessage {
  /// インスタンスを生成する。
  ChatImagesMessage({
    required super.id,
    required super.createdAt,
    required super.sender,
    required this.imageUrls,
    this.selectedImageIndex,
    super.replyTo,
    super.replyImageIndex,
    super.label = 'Images',
  }) : assert(imageUrls.isNotEmpty);

  /// 画像のURL一覧。
  final List<String> imageUrls;

  /// 初期表示時に選択状態とする画像インデックス。
  final int? selectedImageIndex;

  /// 値を置き換えた新しい [ChatImagesMessage] を返する。
  ChatImagesMessage copyWith({
    String? id,
    DateTime? createdAt,
    ChatUser? sender,
    List<String>? imageUrls,
    int? selectedImageIndex,
    ChatUserMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatImagesMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      imageUrls: imageUrls ?? this.imageUrls,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      replyTo: replyTo ?? this.replyTo,
      replyImageIndex: replyImageIndex ?? this.replyImageIndex,
      label: label ?? this.label,
    );
  }

  @override
  String toString() =>
      'ChatImagesMessage('
      'id: $id, '
      'createdAt: $createdAt, '
      'sender: $sender, '
      'imageUrls: $imageUrls, '
      'selectedImageIndex: $selectedImageIndex, '
      'replyTo: $replyTo, '
      'replyImageIndex: $replyImageIndex, '
      'label: $label'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
                other is ChatImagesMessage &&
                (identical(other.id, id) || other.id == id) &&
                (identical(other.createdAt, createdAt) ||
                    other.createdAt == createdAt) &&
                (identical(other.sender, sender) || other.sender == sender) &&
                const ListEquality<String>().equals(
                  other.imageUrls,
                  imageUrls,
                ) &&
                (identical(other.selectedImageIndex, selectedImageIndex) ||
                    other.selectedImageIndex == selectedImageIndex) &&
                (identical(other.replyTo, replyTo) ||
                    other.replyTo == replyTo) &&
                (identical(other.replyImageIndex, replyImageIndex) ||
                    other.replyImageIndex == replyImageIndex)) &&
            (identical(other.label, label) || other.label == label);
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    sender,
    const ListEquality<String>().hash(imageUrls),
    selectedImageIndex,
    replyTo,
    replyImageIndex,
    label,
  ]);
}

/// 画像メッセージのタップコールバック。
typedef ImageMessageTapCallback =
    void Function({required List<String> imageUrls, required int index});

/// コレクションメッセージ。
@immutable
class ChatCollectionMessage extends ChatUserMessage {
  /// インスタンスを生成する。
  const ChatCollectionMessage({
    required super.id,
    required super.createdAt,
    required super.sender,
    required this.collection,
    super.replyTo,
    super.replyImageIndex,
    super.label = 'Collection',
  });

  /// コレクション。
  final Collection collection;

  /// 値を置き換えた新しい [ChatCollectionMessage] を返する。
  ChatCollectionMessage copyWith({
    String? id,
    DateTime? createdAt,
    ChatUser? sender,
    Collection? collection,
    ChatTextMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatCollectionMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      collection: collection ?? this.collection,
      replyTo: replyTo ?? this.replyTo,
      replyImageIndex: replyImageIndex ?? this.replyImageIndex,
      label: label ?? this.label,
    );
  }

  @override
  String toString() =>
      'ChatCollectionMessage('
      'id: $id, '
      'createdAt: $createdAt, '
      'sender: $sender, '
      'collection: $collection, '
      'replyTo: $replyTo, '
      'replyImageIndex: $replyImageIndex, '
      'label: $label'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
                other is ChatCollectionMessage &&
                (identical(other.id, id) || other.id == id) &&
                (identical(other.createdAt, createdAt) ||
                    other.createdAt == createdAt) &&
                (identical(other.sender, sender) || other.sender == sender) &&
                (identical(other.collection, collection) ||
                    other.collection == collection) &&
                (identical(other.replyTo, replyTo) ||
                    other.replyTo == replyTo) &&
                (identical(other.replyImageIndex, replyImageIndex) ||
                    other.replyImageIndex == replyImageIndex)) &&
            (identical(other.label, label) || other.label == label);
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    sender,
    collection,
    replyTo,
    replyImageIndex,
    label,
  ]);
}

/// スタンプメッセージ。
@immutable
class ChatStickerMessage extends ChatUserMessage {
  /// インスタンスを生成する。
  const ChatStickerMessage({
    required super.id,
    required super.createdAt,
    required super.sender,
    required this.sticker,
    super.replyTo,
    super.replyImageIndex,
    super.label = 'Sticker',
  });

  /// スタンプ。
  final Sticker sticker;

  /// 値を置き換えた新しい [ChatStickerMessage] を返する。
  ChatStickerMessage copyWith({
    String? id,
    DateTime? createdAt,
    ChatUser? sender,
    Sticker? sticker,
    ChatTextMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatStickerMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      sticker: sticker ?? this.sticker,
      replyTo: replyTo ?? this.replyTo,
      replyImageIndex: replyImageIndex ?? this.replyImageIndex,
      label: label ?? this.label,
    );
  }

  @override
  String toString() =>
      'ChatStickerMessage('
      'id: $id, '
      'createdAt: $createdAt, '
      'sender: $sender, '
      'sticker: $sticker, '
      'replyTo: $replyTo, '
      'replyImageIndex: $replyImageIndex, '
      'label: $label'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
                other is ChatStickerMessage &&
                (identical(other.id, id) || other.id == id) &&
                (identical(other.createdAt, createdAt) ||
                    other.createdAt == createdAt) &&
                (identical(other.sender, sender) || other.sender == sender) &&
                (identical(other.sticker, sticker) ||
                    other.sticker == sticker) &&
                (identical(other.replyTo, replyTo) ||
                    other.replyTo == replyTo) &&
                (identical(other.replyImageIndex, replyImageIndex) ||
                    other.replyImageIndex == replyImageIndex)) &&
            (identical(other.label, label) || other.label == label);
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    sender,
    sticker,
    replyTo,
    replyImageIndex,
    label,
  ]);
}

/// 音声通話の種類。
enum VoiceCallType {
  /// 通話成立。
  ///
  /// 音声通話が行われた。
  connected,

  /// 受信者による応答なし。
  ///
  /// 受信者が時間内に応答しなかった。
  unanswered
  ;

  /// text を実行する。
  String text({required bool isMine}) => switch (this) {
    VoiceCallType.connected => 'Voice call',
    VoiceCallType.unanswered => isMine ? 'No answer' : 'Missed call',
  };
}

@immutable
/// ChatVoiceCallMessage を表すクラス。
class ChatVoiceCallMessage extends ChatUserMessage {
  /// インスタンスを生成する。
  const ChatVoiceCallMessage({
    required super.id,
    required super.createdAt,
    required super.sender,
    required this.voiceCallType,
    this.durationSeconds,
    super.replyTo,
    super.replyImageIndex,
    super.label = 'VoiceCall',
  }) : assert(
         voiceCallType == VoiceCallType.connected
             ? durationSeconds != null
             : durationSeconds == null,
         'durationSeconds must not be null when VoiceCallType is connected, '
         'and null otherwise',
       );

  /// 音声通話の種類。
  final VoiceCallType voiceCallType;

  /// 通話時間(秒)。
  final int? durationSeconds;

  /// 値を置き換えた新しい [ChatVoiceCallMessage] を返する。
  ChatVoiceCallMessage copyWith({
    String? id,
    DateTime? createdAt,
    ChatUser? sender,
    VoiceCallType? voiceCallType,
    int? durationSeconds,
    ChatTextMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatVoiceCallMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      voiceCallType: voiceCallType ?? this.voiceCallType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      replyTo: replyTo ?? this.replyTo,
      replyImageIndex: replyImageIndex ?? this.replyImageIndex,
      label: label ?? this.label,
    );
  }

  @override
  String toString() =>
      'ChatVoiceCallMessage('
      'id: $id, '
      'createdAt: $createdAt, '
      'sender: $sender, '
      'voiceCallType: $voiceCallType, '
      'durationSeconds: $durationSeconds, '
      'replyTo: $replyTo, '
      'replyImageIndex: $replyImageIndex, '
      'label: $label'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
                other is ChatVoiceCallMessage &&
                (identical(other.id, id) || other.id == id) &&
                (identical(other.createdAt, createdAt) ||
                    other.createdAt == createdAt) &&
                (identical(other.sender, sender) || other.sender == sender) &&
                (identical(other.voiceCallType, voiceCallType) ||
                    other.voiceCallType == voiceCallType) &&
                (identical(other.durationSeconds, durationSeconds) ||
                    other.durationSeconds == durationSeconds) &&
                (identical(other.replyTo, replyTo) ||
                    other.replyTo == replyTo) &&
                (identical(other.replyImageIndex, replyImageIndex) ||
                    other.replyImageIndex == replyImageIndex)) &&
            (identical(other.label, label) || other.label == label);
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    sender,
    voiceCallType,
    durationSeconds,
    replyTo,
    replyImageIndex,
    label,
  ]);
}

/// システムメッセージ。
///
/// 入室退室のメッセージ等で使用する。
@immutable
class ChatSystemMessage implements ChatMessage {
  /// インスタンスを生成する。
  const ChatSystemMessage({
    required this.id,
    required this.createdAt,
    required this.text,
  });

  /// メッセージID。
  @override
  final String id;

  /// 作成日時。
  @override
  final DateTime createdAt;

  /// テキスト。
  final String text;

  /// copyWith を実行する。
  ChatSystemMessage copyWith({String? id, DateTime? createdAt, String? text}) {
    return ChatSystemMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
    );
  }

  @override
  String toString() =>
      'ChatSystemMessage('
      'id: $id, '
      'createdAt: $createdAt, '
      'text: $text'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatSystemMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hashAll([id, createdAt, text]);
}

@immutable
/// ChatUser を表すクラス。
class ChatUser {
  /// インスタンスを生成する。
  const ChatUser({
    required this.id,
    this.isOwner = false,
    required this.name,
    this.avatarImageUrl,
    this.defaultAvatarImageAssetPath,
  }) : assert(
         avatarImageUrl != null || defaultAvatarImageAssetPath != null,
         'Either avatarImageUrl or defaultAvatarImageAssetPath must be set.',
       );

  /// ユーザーID。
  final String id;

  /// 管理者かどうか。
  ///
  /// グループチャットの場合に使用する。
  final bool isOwner;

  /// 名前。
  final String name;

  /// アバター画像のURL。
  final String? avatarImageUrl;

  /// デフォルトで使用するアバター画像のアセットパス。
  final String? defaultAvatarImageAssetPath;

  /// 値を置き換えた新しい [ChatUser] を返する。
  ChatUser copyWith({
    String? id,
    bool? isOwner,
    String? name,
    String? avatarImageUrl,
    String? defaultAvatarImageAssetPath,
  }) {
    return ChatUser(
      id: id ?? this.id,
      isOwner: isOwner ?? this.isOwner,
      name: name ?? this.name,
      avatarImageUrl: avatarImageUrl ?? this.avatarImageUrl,
      defaultAvatarImageAssetPath:
          defaultAvatarImageAssetPath ?? this.defaultAvatarImageAssetPath,
    );
  }

  @override
  String toString() {
    return 'ChatUser('
        'id: $id, '
        'isOwner: $isOwner, '
        'name: $name, '
        'avatarImageUrl: $avatarImageUrl, '
        'defaultAvatarImageAssetPath: $defaultAvatarImageAssetPath'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatUser &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isOwner, isOwner) || other.isOwner == isOwner) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarImageUrl, avatarImageUrl) ||
                other.avatarImageUrl == avatarImageUrl) &&
            (identical(
                  other.defaultAvatarImageAssetPath,
                  defaultAvatarImageAssetPath,
                ) ||
                other.defaultAvatarImageAssetPath ==
                    defaultAvatarImageAssetPath));
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    isOwner,
    name,
    avatarImageUrl,
    defaultAvatarImageAssetPath,
  ]);
}

/// ポップアップメニューで使用するレイアウト。
@immutable
class PopupMenuLayout {
  /// インスタンスを生成する。
  PopupMenuLayout({required this.column, required this.buttonItems})
    : assert(buttonItems.isNotEmpty, 'Popup button items must not be empty.'),
      assert(
        buttonItems.length % column == 0,
        'Popup items must be divisible by column. ',
      );

  /// メニューの列数。
  final int column;

  /// メニューアイテムの配列。
  final List<PopupMenuButtonItem> buttonItems;
}

/// ポップアップメニューで使用するタップ可能なアイテム。
@immutable
class PopupMenuButtonItem {
  /// インスタンスを生成する。
  const PopupMenuButtonItem({
    this.title,
    required this.iconWidget,
    required this.onTap,
  });

  /// アイテムに表示するタイトル。
  final String? title;

  /// アイテムに表示するアイコンWidget。
  final Widget iconWidget;

  /// タップされた時の処理。
  final ValueChanged<ChatUserMessage> onTap;
}

/// メッセージの種類。
/// 入力欄の切り替えに使用する。
enum MessageInputType {
  /// テキストメッセージ。
  text,

  /// スタンプメッセージ。
  sticker,
}

/// コレクション。
@immutable
class Collection {
  /// インスタンスを生成する。
  const Collection({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    required this.linkCount,
    this.latestLinkUrl,
  });

  /// コレクションを一意に識別するID。
  final int id;

  /// コレクション名。
  final String name;

  /// コレクションの説明。
  final String? description;

  /// コレクションのサムネイル画像のURL。
  final String? thumbnailUrl;

  /// コレクションに登録されているリンクの数。
  final int linkCount;

  /// コレクションに登録されている最新のリンクのURL。
  final String? latestLinkUrl;

  @override
  String toString() =>
      'Collection('
      'id: $id, '
      'name: $name, '
      'description: $description, '
      'thumbnailUrl: $thumbnailUrl, '
      'linkCount: $linkCount, '
      'latestLinkUrl: $latestLinkUrl'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Collection &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.linkCount, linkCount) ||
                other.linkCount == linkCount) &&
            (identical(other.latestLinkUrl, latestLinkUrl) ||
                other.latestLinkUrl == latestLinkUrl));
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    description,
    thumbnailUrl,
    linkCount,
    latestLinkUrl,
  ]);
}

/// スタンプパッケージ。
@immutable
class StickerPackage {
  /// インスタンスを生成する。
  const StickerPackage({
    required this.id,
    required this.tabStickerImageUrl,
    required this.stickers,
  });

  /// パッケージを一意に識別するID。
  final int id;

  /// スタンプ選択のタブで使用する画像のURL。
  final String tabStickerImageUrl;

  /// スタンプ一覧。
  final List<Sticker> stickers;

  @override
  String toString() =>
      'StickerPackage('
      'id: $id, '
      'tabStickerImageUrl: $tabStickerImageUrl, '
      'stickers: $stickers'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StickerPackage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tabStickerImageUrl, tabStickerImageUrl) ||
                other.tabStickerImageUrl == tabStickerImageUrl) &&
            (identical(other.stickers, stickers) ||
                other.stickers == stickers));
  }

  @override
  int get hashCode => Object.hashAll([id, tabStickerImageUrl, stickers]);
}

/// スタンプ。
@immutable
class Sticker {
  /// インスタンスを生成する。
  const Sticker({required this.id, required this.imageUrl});

  /// スタンプID。
  final int id;

  /// スタンプ画像のURL。
  final String imageUrl;

  @override
  String toString() =>
      'Sticker('
      'id: $id, '
      'imageUrl: $imageUrl'
      ')';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Sticker &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hashAll([id, imageUrl]);
}
