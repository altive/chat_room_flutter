import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'sticker.dart';

/// {@template altive_chat_room.StickerPackage}
/// ステッカーパッケージ。
/// {@endtemplate}
@immutable
class StickerPackage extends Equatable {
  /// {@macro altive_chat_room.StickerPackage}
  const StickerPackage({
    required this.id,
    required this.tabStickerImageUrl,
    required this.stickers,
    this.isLocked = false,
  });

  /// パッケージを一意に識別するID。
  final int id;

  /// ステッカー選択のタブで使用する画像のURL。
  final String tabStickerImageUrl;

  /// ステッカー一覧。
  final List<Sticker> stickers;

  /// 選択時にアプリ側の利用導線を表示するかどうか。
  final bool isLocked;

  @override
  String toString() =>
      'StickerPackage('
      'id: $id, '
      'tabStickerImageUrl: $tabStickerImageUrl, '
      'stickers: $stickers, '
      'isLocked: $isLocked'
      ')';

  @override
  List<Object?> get props => [id, tabStickerImageUrl, stickers, isLocked];
}
