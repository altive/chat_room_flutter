import 'package:flutter/widgets.dart';

import 'model.dart';

/// {@template altive_chat_room.InheritedAltiveChatRoomTheme}
/// [AltiveChatRoomTheme] をツリー全体へ共有する [InheritedWidget]。
/// {@endtemplate}
  class InheritedAltiveChatRoomTheme extends InheritedWidget {
  /// {@macro altive_chat_room.InheritedAltiveChatRoomTheme}
  const InheritedAltiveChatRoomTheme({
    super.key,
    required this.theme,
    required this.messageListViewKey,
    required super.child,
  });

  /// of を実行する。
  static InheritedAltiveChatRoomTheme of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedAltiveChatRoomTheme>()!;

  /// チャットUIのテーマ。
  final AltiveChatRoomTheme theme;

  /// メッセージリストのキー。
  ///
  /// メッセージリストの高さを計算するために使用する。
  final GlobalKey messageListViewKey;

  @override
  bool updateShouldNotify(InheritedAltiveChatRoomTheme oldWidget) =>
      theme.hashCode != oldWidget.theme.hashCode;
}
