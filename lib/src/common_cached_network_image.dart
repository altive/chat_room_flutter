import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'adaptive_cached_network_svg_image_wrapper.dart';
import 'cached_local_image.dart';
import 'common_cache_manager.dart';

/// [CachedNetworkImage] のラッパー Widget。
/// SVG画像の場合は [AdaptiveCachedNetworkSVGImage] を使用する。
class CommonCachedNetworkImage extends StatelessWidget {
  /// インスタンスを生成する。
  const CommonCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.progressIndicatorWidth,
    this.progressIndicatorHeight,
    // メモリにキャッシュされる画像の横幅サイズ。
    this.memCacheWidth = 1440,
    // NOTE: 高解像度カメラ画像（約4000px）にも対応できるように、上限を4800pxに設定する。
    // 設定値が低い場合に画像の色味が変わることがある。
    this.maxWidthDiskCache = 4800,
    this.errorWidget,
    this.timeoutDuration = const Duration(seconds: 10),
    // NOTE: レンダリングで出力される画像の品質。
    this.filterQuality = FilterQuality.medium,
  });

  /// 表示対象の画像URL。
  final String imageUrl;

  /// 画像の表示幅。
  final double? width;

  /// 画像の表示高さ。
  final double? height;

  /// 画像のフィット方法。
  final BoxFit fit;

  /// 読み込み中インジケーターの表示幅。
  final double? progressIndicatorWidth;

  /// 読み込み中インジケーターの表示高さ。
  final double? progressIndicatorHeight;

  /// メモリキャッシュ時の画像幅（px）。
  final int? memCacheWidth;

  /// ディスクキャッシュ時の最大画像幅（px）。
  final int? maxWidthDiskCache;

  /// 読み込み失敗時に表示するウィジェット。
  final Widget? errorWidget;

  /// 読み込み待機のタイムアウト時間。
  final Duration timeoutDuration;

  /// 描画時のフィルター品質。
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    final errorWidget = this.errorWidget ?? const _ErrorIcon();

    final uri = Uri.tryParse(imageUrl);

    // 絶対パスではない場合はエラー表示する
    if (uri == null || !uri.isAbsolute) {
      return errorWidget;
    }

    // data URI の場合は専用 Widget でメモリ上の画像を描画する。
    if (uri.scheme == 'data') {
      return CachedLocalImage(
        dataUri: imageUrl,
        fit: fit,
        width: width,
        height: height,
        filterQuality: filterQuality,
        errorWidget: errorWidget,
      );
    }

    // SVG画像の場合
    if (imageUrl.endsWith('.svg')) {
      return AdaptiveCachedNetworkSVGImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorWidget: errorWidget,
        fadeDuration: const Duration(milliseconds: 100),
        cacheManager: CommonCachedNetworkImageProvider.commonCacheManager,
        timeoutDuration: timeoutDuration,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      // デフォルトの 500 milliseconds では長く感じるので短くする
      fadeInDuration: const Duration(milliseconds: 100),
      // PlaceholderやProgressIndicatorが消える長さ
      // デフォルトの 1000 milliseconds では長く感じるので短くする
      fadeOutDuration: const Duration(milliseconds: 100),
      // ダウンロードした画像ファイルが大きいので、メモリ上の画像を一定の幅にリサイズしてキャッシュする
      memCacheWidth: memCacheWidth,
      maxWidthDiskCache: maxWidthDiskCache,
      filterQuality: filterQuality,
      cacheManager: CommonCachedNetworkImageProvider.commonCacheManager,
      // 画像ダウンロードに時間がかかる場合に進捗を表示する
      progressIndicatorBuilder: (_, _, progress) {
        return FutureBuilder(
          future: Future<void>.delayed(timeoutDuration),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return errorWidget;
            }

            return SizedBox(
              width: progressIndicatorWidth,
              height: progressIndicatorHeight,
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  value: progress.progress,
                ),
              ),
            );
          },
        );
      },
      // エラーで画像が表示できない時、真っ白な表示ではなくエラー用のWidgetを表示させる
      errorWidget: (_, _, _) => errorWidget,
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.error,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

/// [CachedNetworkImageProvider] のラッパークラス。
class CommonCachedNetworkImageProvider extends CachedNetworkImageProvider {
  /// インスタンスを生成する。
  CommonCachedNetworkImageProvider(super.url)
    : super(cacheManager: commonCacheManager);

  /// キャッシュの共通設定を使用するため、共通のキャッシュマネージャーを使用する。
  static CacheManager _cacheManager = CommonCacheManager();

  /// 共通設定のキャッシュマネージャーを取得する。
  static CacheManager get commonCacheManager => _cacheManager;

  /// テスト用にキャッシュマネージャーを差し替えるためのセッター。
  @visibleForTesting
  static set commonCacheManager(CacheManager manager) {
    _cacheManager = manager;
  }
}
