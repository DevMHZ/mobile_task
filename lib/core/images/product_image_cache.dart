import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'image_policy.dart';

/// One cache manager per cache key, shared by cards, details and gallery.
abstract final class ProductImageCache {
  static final CacheManager instance = CacheManager(
    Config(
      ImagePolicy.cacheKey,
      stalePeriod: ImagePolicy.unusedRetention,
      maxNrOfCacheObjects: ImagePolicy.maxDiskEntries,
    ),
  );
}
