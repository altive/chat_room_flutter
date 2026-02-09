import 'package:flutter/widgets.dart';

import 'model.dart';

/// [AltiveChatRoomTheme]クラスをパッケージ全体を通して利用可能にするために使用されます。
class InheritedAltiveChatRoomTheme extends InheritedWidget {
  /// インスタンスを生成する。
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
