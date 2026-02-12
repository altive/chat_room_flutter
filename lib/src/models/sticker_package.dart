import 'package:flutter/foundation.dart';

import 'sticker.dart';

/// {@template altive_chat_room.StickerPackage}
/// ステッカーパッケージ。
/// {@endtemplate}
@immutable
class StickerPackage {
  /// {@macro altive_chat_room.StickerPackage}
  const StickerPackage({
    required this.id,
    required this.tabStickerImageUrl,
    required this.stickers,
  });

  /// パッケージを一意に識別するID。
  final int id;

  /// ステッカー選択のタブで使用する画像のURL。
  final String tabStickerImageUrl;

  /// ステッカー一覧。
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
