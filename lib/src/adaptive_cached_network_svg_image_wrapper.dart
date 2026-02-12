// NOTE: プラットフォーム別の実装を切り替えるためのファイル。
// cached_network_svg_image が Flutter Web で動作しないため、条件付きエクスポートを使用する。
// アプリでは dart.library.io が true になる。
export 'adaptive_cached_network_svg_image_web.dart'
    if (dart.library.io) 'adaptive_cached_network_svg_image_mobile.dart';
