import 'package:flutter/material.dart';

import 'common_cached_network_image.dart';
import 'models.dart';

/// {@template altive_chat_room.AvatarImage}
/// ユーザーのアバター画像を表示するWidget。
/// {@endtemplate}
class AvatarImage extends StatelessWidget {
  /// {@macro altive_chat_room.AvatarImage}
  const AvatarImage({
    super.key,
    required this.user,
    required this.sizeDimension,
    this.onAvatarTap,
  });

  /// アバターを表示するユーザー情報。
  final ChatUser user;

  /// アバターの直径。
  final double sizeDimension;

  /// アバタータップ時のコールバック。
  final ValueChanged<ChatUser>? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarImageUrl = user.avatarImageUrl;
    return GestureDetector(
      onTap: () => onAvatarTap?.call(user),
      child: ClipOval(
        child: avatarImageUrl == null
            // avatarImageUrlがnullの場合はdefaultAvatarImageAssetPathが必ず存在する。
            ? Image.asset(
                user.defaultAvatarImageAssetPath!,
                fit: BoxFit.cover,
                width: sizeDimension,
                height: sizeDimension,
              )
            : CommonCachedNetworkImage(
                imageUrl: avatarImageUrl,
                width: sizeDimension,
                height: sizeDimension,
                progressIndicatorWidth: sizeDimension,
                progressIndicatorHeight: sizeDimension,
                errorWidget: ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
      ),
    );
  }
}
