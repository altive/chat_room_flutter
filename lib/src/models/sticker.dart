import 'package:flutter/foundation.dart';

/// {@template altive_chat_room.Sticker}
/// ステッカー。
/// {@endtemplate}
@immutable
class Sticker {
  /// {@macro altive_chat_room.Sticker}
  const Sticker({required this.id, required this.imageUrl});

  /// ステッカーID。
  final int id;

  /// ステッカー画像のURL。
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
