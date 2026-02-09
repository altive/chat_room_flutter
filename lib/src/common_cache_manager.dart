import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// {@template altive_chat_room.CommonCacheManager}
/// 画像キャッシュの共通設定を提供するキャッシュマネージャー。
/// {@endtemplate}
class CommonCacheManager extends CacheManager {
  /// {@macro altive_chat_room.CommonCacheManager}
  CommonCacheManager()
    : super(
        Config(
          'altive_chat_room_common_cache',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 200,
        ),
      );
}
