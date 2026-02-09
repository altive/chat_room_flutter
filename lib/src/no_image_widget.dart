import 'package:flutter/material.dart';

import 'inherited_altive_chat_room_theme.dart';

enum _NoImageSize { s, l }

/// お気に入りコンテンツのサムネイル画像がない場合に表示するWidget。
class NoImageWidget extends StatelessWidget {
  /// 小サイズのプレースホルダーを生成する。
  const NoImageWidget.s({super.key}) : size = _NoImageSize.s;

  /// 大サイズのプレースホルダーを生成する。
  const NoImageWidget.l({super.key}) : size = _NoImageSize.l;

  /// サイズ。
  final _NoImageSize size;

  @override
  Widget build(BuildContext context) {
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    const text = 'No Image';

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: altiveChatRoomTheme.favoriteCollectionNoImageBackgroundColor,
      ),
      child: switch (size) {
        _NoImageSize.s => Container(
          width: 68,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: altiveChatRoomTheme
                    .favoriteCollectionNoImageTextStyle
                    ?.color,
                size: 18,
              ),
              Text(
                text,
                style: altiveChatRoomTheme.favoriteCollectionNoImageTextStyle,
              ),
            ],
          ),
        ),
        _NoImageSize.l => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              color:
                  altiveChatRoomTheme.favoriteCollectionNoImageTextStyle?.color,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: altiveChatRoomTheme.favoriteCollectionNoImageTextStyle,
            ),
          ],
        ),
      },
    );
  }
}
