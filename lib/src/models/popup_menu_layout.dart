import 'package:flutter/foundation.dart';

import 'popup_menu_button_item.dart';

/// {@template altive_chat_room.PopupMenuLayout}
/// ポップアップメニューで使用するレイアウト。
/// {@endtemplate}
@immutable
class PopupMenuLayout {
  /// {@macro altive_chat_room.PopupMenuLayout}
  PopupMenuLayout({required this.column, required this.buttonItems})
    : assert(buttonItems.isNotEmpty, 'Popup button items must not be empty.'),
      assert(
        buttonItems.length % column == 0,
        'Popup items must be divisible by column. ',
      );

  /// メニューの列数。
  final int column;

  /// メニューアイテムの配列。
  final List<PopupMenuButtonItem> buttonItems;
}
