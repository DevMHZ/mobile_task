import 'package:flutter/painting.dart';

/// Buckets limit duplicate decoded variants during resize and orientation changes.
abstract final class ImagePolicy {
  static const decodeBuckets = [128, 256, 512, 1024, 2048];
  static const galleryScale = 2.0;
  static const galleryMaxZoom = 4.0;
  static const cacheKey = 'mobile_task_product_images_v1';
  static const maxDiskEntries = 200;
  static const unusedRetention = Duration(days: 14);

  static Size decodeSize(Size logical, double pixelRatio, {double scale = 1}) =>
      Size(
        _bucket(logical.width * pixelRatio * scale).toDouble(),
        _bucket(logical.height * pixelRatio * scale).toDouble(),
      );

  static int _bucket(double value) {
    if (!value.isFinite || value <= 0) return decodeBuckets.last;
    return decodeBuckets.firstWhere(
      (bucket) => bucket >= value.ceil(),
      orElse: () => decodeBuckets.last,
    );
  }
}
