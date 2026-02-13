import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// {@template altive_chat_room.Sticker}
/// ステッカー。
/// {@endtemplate}
@immutable
class Sticker extends Equatable {
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
  List<Object?> get props => [id, imageUrl];
}
