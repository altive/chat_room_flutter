import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// {@template altive_chat_room.CommonCacheManager}
/// 画像キャッシュの共通設定を提供するキャッシュマネージャー。
///
/// - キャッシュ期間: 7 日間
/// - キャッシュオブジェクトの最大数: 50 個
/// {@endtemplate}
/// `flutter_cache_manager` の仕様として、キャッシュオブジェクトの最大数に小さな値を設定しても、
/// 対象のキャッシュが最後に使用されてから 1 日以上経過していない場合は削除されない。
///
/// 元々のデフォルト値は以下を参照。
/// https://github.com/Baseflow/flutter_cache_manager/blob/develop/flutter_cache_manager/lib/src/config/_config_io.dart#L14-L15
class CommonCacheManager extends CacheManager with ImageCacheManager {
  /// {@macro altive_chat_room.CommonCacheManager}
  factory CommonCacheManager() => _instance;

  /// {@macro altive_chat_room.CommonCacheManager}
  CommonCacheManager._() : super(_config);

  /// 後方互換性のため、`cached_network_image` のデフォルトのキーを使用している。
  static const String key = DefaultCacheManager.key;

  static final _instance = CommonCacheManager._();

  static final _config = Config(
    key,
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 50,
  );
}
