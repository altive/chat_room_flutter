import 'package:flutter/widgets.dart';

/// 引用タップ処理を返信表示へ伝える内部scope。
class ChatReplyScope extends InheritedWidget {
  /// 引用タップ処理と子Widgetを保持する。
  const ChatReplyScope({
    super.key,
    required this.onReferenceTap,
    required super.child,
  });

  /// 引用をタップしたときの処理。
  final void Function(String messageId, int? imageIndex)? onReferenceTap;

  /// 最も近いscopeを返す。
  static ChatReplyScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatReplyScope>();

  /// callbackが変化した場合だけ子Widgetへ通知する。
  @override
  bool updateShouldNotify(ChatReplyScope oldWidget) =>
      onReferenceTap != oldWidget.onReferenceTap;
}
