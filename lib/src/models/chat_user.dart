import 'package:flutter/foundation.dart';

/// {@template altive_chat_room.ChatUser}
/// チャットで利用するユーザー情報。
/// {@endtemplate}
@immutable
class ChatUser {
  /// {@macro altive_chat_room.ChatUser}
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
