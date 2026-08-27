import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'chat_user.dart';
import 'sticker.dart';

/// ChatMessage を表すクラス。
@immutable
sealed class ChatMessage extends Equatable {
  const ChatMessage({required this.id, required this.createdAt});

  /// メッセージID。
  final String id;

  /// 作成日時。
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, createdAt];
}

/// ユーザーが送信するメッセージ。
@immutable
sealed class ChatUserMessage extends ChatMessage {
  const ChatUserMessage({
    required super.id,
    required super.createdAt,
    required this.sender,
    this.deliveryState = ChatMessageDeliveryState.sent,
    this.isRead = false,
    this.replyTo,
    this.replyImageIndex,
    required this.label,
  });

  /// 送信者。
  final ChatUser sender;

  /// メッセージの送信状態。
  final ChatMessageDeliveryState deliveryState;

  /// 既読状態。
  ///
  /// 相手送信メッセージでは、未読として扱い何も表示しない。
  final bool isRead;

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
  bool isOutgoing({required String currentUserId}) {
    return sender.id == currentUserId;
  }

  @override
  List<Object?> get props => [
    ...super.props,
    sender,
    deliveryState,
    isRead,
    replyTo,
    replyImageIndex,
    label,
  ];
}

/// 送信メッセージの配信状態。
enum ChatMessageDeliveryState {
  /// 送信中。
  sending,

  /// 送信済み。
  sent,

  /// 送信に失敗し、再送できる状態。
  failed,
}

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
    super.deliveryState,
    required this.text,
    this.highlight = false,
    this.button,
    super.isRead,
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
    ChatMessageDeliveryState? deliveryState,
    String? text,
    bool? highlight,
    MessageActionButton? button,
    bool? isRead,
    ChatUserMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatTextMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      deliveryState: deliveryState ?? this.deliveryState,
      text: text ?? this.text,
      highlight: highlight ?? this.highlight,
      button: button ?? this.button,
      isRead: isRead ?? this.isRead,
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
      'isRead: $isRead, '
      'replyTo: $replyTo, '
      'replyImageIndex: $replyImageIndex, '
      'label: $label'
      ')';

  @override
  List<Object?> get props => [...super.props, text, highlight, button];
}

/// {@template altive_chat_room.MessageActionButton}
/// メッセージ下部に表示するボタン。
/// {@endtemplate}
@immutable
class MessageActionButton extends Equatable {
  /// {@macro altive_chat_room.MessageActionButton}
  const MessageActionButton({required this.text, required this.value});

  /// ボタンに表示するテキスト。
  final String text;

  /// ボタンがタップされた際に送信される値。
  final Object? value;

  @override
  String toString() =>
      'MessageActionButton('
      'text: $text, '
      'value: $value'
      ')';

  @override
  List<Object?> get props => [text, value];
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
    super.deliveryState,
    super.isRead,
    required List<String> imageUrls,
    List<double>? imageAspectRatios,
    bool? hasExplicitImageAspectRatios,
    this.caption,
    this.selectedImageIndex,
    super.replyTo,
    super.replyImageIndex,
    super.label = 'Images',
  }) : imageUrls = List.unmodifiable(imageUrls),
       imageAspectRatios = List.unmodifiable(
         imageAspectRatios ?? List.filled(imageUrls.length, 1.0),
       ),
       hasExplicitImageAspectRatios =
           hasExplicitImageAspectRatios ?? imageAspectRatios != null,
       assert(imageUrls.isNotEmpty),
       assert(
         imageAspectRatios == null ||
             imageAspectRatios.length == imageUrls.length,
       );

  /// 画像のURL一覧。
  final List<String> imageUrls;

  /// 各画像の高さを幅で割った縦横比。
  final List<double> imageAspectRatios;

  /// 利用側から実画像の縦横比が明示されたかどうか。
  ///
  /// 未指定時は画像自身の寸法でレイアウトするために使用する。
  final bool hasExplicitImageAspectRatios;

  /// 画像と同じ送信単位で表示する本文。
  final String? caption;

  /// 初期表示時に選択状態とする画像インデックス。
  final int? selectedImageIndex;

  /// 値を置き換えた新しい [ChatImagesMessage] を返する。
  ChatImagesMessage copyWith({
    String? id,
    DateTime? createdAt,
    ChatUser? sender,
    ChatMessageDeliveryState? deliveryState,
    bool? isRead,
    List<String>? imageUrls,
    List<double>? imageAspectRatios,
    String? caption,
    int? selectedImageIndex,
    ChatUserMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatImagesMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      deliveryState: deliveryState ?? this.deliveryState,
      isRead: isRead ?? this.isRead,
      imageUrls: imageUrls ?? this.imageUrls,
      imageAspectRatios:
          imageAspectRatios ??
          (imageUrls == null ? this.imageAspectRatios : null),
      hasExplicitImageAspectRatios:
          imageAspectRatios != null ||
          (imageUrls == null && hasExplicitImageAspectRatios),
      caption: caption ?? this.caption,
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
      'caption: $caption, '
      'selectedImageIndex: $selectedImageIndex, '
      'replyTo: $replyTo, '
      'replyImageIndex: $replyImageIndex, '
      'label: $label'
      ')';

  @override
  List<Object?> get props => [
    ...super.props,
    imageUrls,
    imageAspectRatios,
    hasExplicitImageAspectRatios,
    caption,
    selectedImageIndex,
  ];
}

/// 画像メッセージのタップコールバック。
typedef ImageMessageTapCallback =
    void Function({required List<String> imageUrls, required int index});

/// 画像メッセージのIDと画像位置を通知するタップコールバック。
typedef ChatImageTapCallback =
    void Function({required String messageId, required int index});

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
    super.deliveryState,
    super.isRead,
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
    ChatMessageDeliveryState? deliveryState,
    bool? isRead,
    Sticker? sticker,
    ChatUserMessage? replyTo,
    int? replyImageIndex,
    String? label,
  }) {
    return ChatStickerMessage(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      deliveryState: deliveryState ?? this.deliveryState,
      isRead: isRead ?? this.isRead,
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
  List<Object?> get props => [...super.props, sticker];
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
  unanswered;

  /// text を実行する。
  String text({required bool isOutgoing}) => switch (this) {
    VoiceCallType.connected => 'Voice call',
    VoiceCallType.unanswered => isOutgoing ? 'No answer' : 'Missed call',
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
    super.deliveryState,
    super.isRead,
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
    ChatMessageDeliveryState? deliveryState,
    bool? isRead,
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
      deliveryState: deliveryState ?? this.deliveryState,
      isRead: isRead ?? this.isRead,
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
  List<Object?> get props => [...super.props, voiceCallType, durationSeconds];
}

/// {@template altive_chat_room.ChatSystemMessage}
/// システムメッセージ。
///
/// 入室退室のメッセージ等で使用する。
/// {@endtemplate}
@immutable
class ChatSystemMessage extends ChatMessage {
  /// {@macro altive_chat_room.ChatSystemMessage}
  const ChatSystemMessage({
    required super.id,
    required super.createdAt,
    required this.text,
  });

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
  List<Object?> get props => [...super.props, text];
}
