import 'package:flutter/material.dart';

import 'chat_message.dart';

/// {@template altive_chat_room.PopupMenuButtonItem}
/// ポップアップメニューで使用するタップ可能なアイテム。
/// {@endtemplate}
@immutable
class PopupMenuButtonItem {
  /// {@macro altive_chat_room.PopupMenuButtonItem}
  const PopupMenuButtonItem({
    this.title,
    required this.iconWidget,
    required this.onTap,
  });

  /// アイテムに表示するタイトル。
  final String? title;

  /// アイテムに表示するアイコンWidget。
  final Widget iconWidget;

  /// タップされた時の処理。
  final ValueChanged<ChatUserMessage> onTap;
}
