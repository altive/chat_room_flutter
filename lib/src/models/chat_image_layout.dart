import 'package:flutter/widgets.dart';

/// 複数画像メッセージの配置方法。
enum ChatMultipleImageLayout {
  /// 3枚では先頭を横長にし、残りを下段の2列で表示する。
  ///
  /// 4枚以上は2×2へ収め、4枚目に超過件数を表示する。
  leadingWideGrid,

  /// 3枚では先頭を大きく、残り2枚を右側へ並べる。
  ///
  /// 4枚以上は2×2へ収め、4枚目に超過件数を表示する。
  mosaic,
}

/// 単一画像メッセージの配置設定。
@immutable
class ChatSingleImageLayout {
  /// 正方形で表示する設定。
  const ChatSingleImageLayout.square()
    : minHeight = null,
      maxHeight = null,
      fit = BoxFit.cover;

  /// 元の縦横比を尊重し、指定した高さの範囲で表示する設定。
  const ChatSingleImageLayout.adaptiveBounded({
    double minHeight = 160,
    double maxHeight = 260,
    this.fit = BoxFit.cover,
  }) : minHeight = minHeight,
       maxHeight = maxHeight,
       assert(minHeight > 0),
       assert(maxHeight >= minHeight);

  /// 最小表示高さ。`null`の場合は正方形表示。
  final double? minHeight;

  /// 最大表示高さ。`null`の場合は正方形表示。
  final double? maxHeight;

  /// 画像の収め方。
  final BoxFit fit;

  /// 元画像の縦横比を利用するかどうか。
  bool get isAdaptive => minHeight != null;
}

/// チャット画像のレイアウト設定。
@immutable
class ChatImageLayoutConfiguration {
  /// チャット画像のレイアウト設定を生成する。
  const ChatImageLayoutConfiguration({
    this.singleImageLayout = const ChatSingleImageLayout.adaptiveBounded(),
    this.multipleImageLayout = ChatMultipleImageLayout.leadingWideGrid,
  });

  /// 単一画像の配置設定。
  final ChatSingleImageLayout singleImageLayout;

  /// 複数画像の配置方法。
  final ChatMultipleImageLayout multipleImageLayout;
}
