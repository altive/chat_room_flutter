import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// CommonCacheManager を表すクラス。
class CommonCacheManager extends CacheManager {
  /// インスタンスを生成する。
  CommonCacheManager()
    : super(
        Config(
          'altive_chat_room_common_cache',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 200,
        ),
      );
}
