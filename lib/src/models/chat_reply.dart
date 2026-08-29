import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'sticker.dart';

/// 返信元を再取得せずに引用表示するための軽量な内容。
@immutable
sealed class ChatReplyPreviewContent extends Equatable {
  const ChatReplyPreviewContent();
}

/// テキストの返信preview。
@immutable
class ChatReplyTextPreview extends ChatReplyPreviewContent {
  /// テキストpreviewを作成する。
  const ChatReplyTextPreview(this.value);

  /// 引用表示する本文。
  final String value;

  @override
  List<Object?> get props => [value];
}

/// 画像の返信preview。
@immutable
class ChatReplyImagePreview extends ChatReplyPreviewContent {
  /// 画像previewを作成する。
  const ChatReplyImagePreview({
    this.thumbnailUrl,
    this.caption,
    required this.totalCount,
  }) : assert(totalCount > 0);

  /// 引用表示する画像URL。
  final String? thumbnailUrl;

  /// 画像と一緒に送信された任意の本文。
  final String? caption;

  /// 元メッセージに含まれる画像数。
  final int totalCount;

  @override
  List<Object?> get props => [thumbnailUrl, caption, totalCount];
}

/// ステッカーの返信preview。
@immutable
class ChatReplyStickerPreview extends ChatReplyPreviewContent {
  /// ステッカーpreviewを作成する。
  const ChatReplyStickerPreview(this.sticker);

  /// 引用表示するステッカー。
  final Sticker sticker;

  @override
  List<Object?> get props => [sticker];
}

/// 汎用カードなどの返信preview。
@immutable
class ChatReplyLabelPreview extends ChatReplyPreviewContent {
  /// 汎用ラベルpreviewを作成する。
  const ChatReplyLabelPreview(this.value);

  /// 引用表示する短い文言。
  final String value;

  @override
  List<Object?> get props => [value];
}

/// 削除・非表示などにより内容を表示できない返信preview。
@immutable
class ChatReplyUnavailablePreview extends ChatReplyPreviewContent {
  /// 内容を表示できないpreviewを作成する。
  const ChatReplyUnavailablePreview();

  @override
  List<Object?> get props => const [];
}

/// 返信元の非再帰snapshot。
@immutable
class ChatReplyReference extends Equatable {
  /// 軽量な返信参照を作成する。
  const ChatReplyReference({
    required this.messageId,
    required this.senderId,
    required this.senderDisplayName,
    required this.content,
    this.imageIndex,
  });

  /// 返信元の安定したメッセージID。
  final String messageId;

  /// 返信元の送信者ID。
  final String senderId;

  /// 返信元の送信者表示名。
  final String senderDisplayName;

  /// 引用表示する内容。
  final ChatReplyPreviewContent content;

  /// 複数画像の特定画像へ返信する場合のindex。
  final int? imageIndex;

  @override
  List<Object?> get props => [
    messageId,
    senderId,
    senderDisplayName,
    content,
    imageIndex,
  ];
}
