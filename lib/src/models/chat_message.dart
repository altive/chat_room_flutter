import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'chat_user.dart';
import 'sticker.dart';

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

  /// ログインユーザーが送信したメッセージかどうか。
  bool isSentByCurrentUser(String currentUserId) {
    return sender.id == currentUserId;
  }
}

/// メッセージバブル直下に表示するWidgetを構築するビルダーの型定義。
typedef MessageBottomWidgetBuilder =
    Widget? Function(
      ChatUserMessage message, {
      required bool isSentByCurrentUser,
    });

/// ポップアップメニュー周辺の付属Widgetを構築するビルダーの型定義。
/// [PreferredSizeWidget]を利用し、オーバーレイの幅・高さを安定して算出する。
typedef PopupMenuAccessoryBuilder =
    PreferredSizeWidget? Function(
      ChatUserMessage message, {

      /// ポップアップメニューを閉じたいときに呼び出すコールバック。
      required VoidCallback closePopupMenu,
    });

/// {@template altive_chat_room.ChatTextMessage}
/// テキストメッセージ。
/// {@endtemplate}
@immutable
class ChatTextMessage extends ChatUserMessage {
  /// {@macro altive_chat_room.ChatTextMessage}
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
    ChatUserMessage? replyTo,
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

/// {@template altive_chat_room.MessageActionButton}
/// メッセージ下部に表示するボタン。
/// {@endtemplate}
@immutable
class MessageActionButton {
  /// {@macro altive_chat_room.MessageActionButton}
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

/// {@template altive_chat_room.ChatImagesMessage}
/// 複数画像メッセージ。
/// {@endtemplate}
@immutable
class ChatImagesMessage extends ChatUserMessage {
  /// {@macro altive_chat_room.ChatImagesMessage}
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

/// {@template altive_chat_room.ChatStickerMessage}
/// ステッカーメッセージ。
/// {@endtemplate}
@immutable
class ChatStickerMessage extends ChatUserMessage {
  /// {@macro altive_chat_room.ChatStickerMessage}
  const ChatStickerMessage({
    required super.id,
    required super.createdAt,
    required super.sender,
    required this.sticker,
    super.replyTo,
    super.replyImageIndex,
    super.label = 'Sticker',
  });

  /// ステッカー。
  final Sticker sticker;

  /// 値を置き換えた新しい [ChatStickerMessage] を返する。
  ChatStickerMessage copyWith({
    String? id,
    DateTime? createdAt,
    ChatUser? sender,
    Sticker? sticker,
    ChatUserMessage? replyTo,
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
  String text({required bool isSentByCurrentUser}) => switch (this) {
    VoiceCallType.connected => 'Voice call',
    VoiceCallType.unanswered =>
      isSentByCurrentUser ? 'No answer' : 'Missed call',
  };
}

/// {@template altive_chat_room.ChatVoiceCallMessage}
/// 音声通話メッセージ。
/// {@endtemplate}
@immutable
class ChatVoiceCallMessage extends ChatUserMessage {
  /// {@macro altive_chat_room.ChatVoiceCallMessage}
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
    ChatUserMessage? replyTo,
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

/// {@template altive_chat_room.ChatSystemMessage}
/// システムメッセージ。
///
/// 入室退室のメッセージ等で使用する。
/// {@endtemplate}
@immutable
class ChatSystemMessage implements ChatMessage {
  /// {@macro altive_chat_room.ChatSystemMessage}
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
