import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// {@template altive_chat_room.AdaptiveCachedNetworkSVGImage}
/// Web用のSVG画像表示Widget。
///
/// `cached_network_svg_image` パッケージは Web で使用できないため、
/// Web向けに SVG を表示する。
/// {@endtemplate}
class AdaptiveCachedNetworkSVGImage extends StatelessWidget {
  /// {@macro altive_chat_room.AdaptiveCachedNetworkSVGImage}
  const AdaptiveCachedNetworkSVGImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    required this.errorWidget,
    required this.fadeDuration,
    this.cacheManager,
    required this.timeoutDuration,
    this.progressIndicatorWidth,
    this.progressIndicatorHeight,
  });

  /// 表示する SVG 画像の URL。
  final String imageUrl;

  /// 画像の表示幅。
  final double? width;

  /// 画像の表示高さ。
  final double? height;

  /// 画像のフィット方法。
  final BoxFit fit;

  /// 読み込み失敗時に表示するウィジェット。
  final Widget errorWidget;

  /// フェード表示にかける時間。
  final Duration fadeDuration;

  /// SVG のキャッシュに利用するマネージャー。
  final BaseCacheManager? cacheManager;

  /// 読み込み待機のタイムアウト時間。
  final Duration timeoutDuration;

  /// 読み込み中インジケーターの表示幅。
  final double? progressIndicatorWidth;

  /// 読み込み中インジケーターの表示高さ。
  final double? progressIndicatorHeight;

  @override
  Widget build(BuildContext context) {
    return errorWidget;
  }
}
