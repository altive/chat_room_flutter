import 'package:flutter/widgets.dart';

import 'models.dart';

/// リンクプレビューのRoom単位設定を子Widgetへ渡すscope。
class ChatLinkPreviewScope extends InheritedWidget {
  /// リンクプレビューのRoom単位設定を作成する。
  const ChatLinkPreviewScope({
    required this.resolver,
    required this.imageBuilder,
    required this.onWebLinkTap,
    required this.semanticLabel,
    required this.loadingSemanticLabel,
    required super.child,
    super.key,
  });

  /// 入力中URLのresolver。
  final ChatLinkPreviewResolver? resolver;

  /// 画像loaderの構築処理。
  final ChatLinkPreviewImageBuilder? imageBuilder;

  /// Webリンク操作時の処理。
  final ChatWebLinkTapCallback? onWebLinkTap;

  /// リンクプレビューの読み上げ文。
  final String semanticLabel;

  /// 読み込み中リンクプレビューの読み上げ文。
  final String loadingSemanticLabel;

  /// 最も近いscopeを返す。
  static ChatLinkPreviewScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatLinkPreviewScope>();

  @override
  bool updateShouldNotify(ChatLinkPreviewScope oldWidget) =>
      resolver != oldWidget.resolver ||
      imageBuilder != oldWidget.imageBuilder ||
      onWebLinkTap != oldWidget.onWebLinkTap ||
      semanticLabel != oldWidget.semanticLabel ||
      loadingSemanticLabel != oldWidget.loadingSemanticLabel;
}
