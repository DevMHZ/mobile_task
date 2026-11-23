import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../images/image_policy.dart';
import '../images/product_image_cache.dart';
import '../localization/context_l10n.dart';
import '../theme/app_theme.dart';
import 'app_shimmer.dart';
import 'app_feedback.dart';

class AppNetworkImage extends StatefulWidget {
  const AppNetworkImage({
    required this.url,
    required this.label,
    this.fit = BoxFit.contain,
    this.resolutionScale = 1,
    this.decorative = false,
    this.cacheManager,
    super.key,
  });
  final String url;
  final String label;
  final BoxFit fit;
  final double resolutionScale;
  final bool decorative;
  final BaseCacheManager? cacheManager;
  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  int _attempt = 0;
  bool _retrying = false;
  ResizeImage? _provider;

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _attempt = 0;
      _retrying = false;
    }
  }

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    final url = widget.url;
    try {
      await _provider?.evict();
      await (widget.cacheManager ?? ProductImageCache.instance).removeFile(url);
      if (mounted && widget.url == url) setState(() => _attempt++);
    } on Object {
      if (mounted && widget.url == url) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          AppFeedback.error(messenger, context.l10n.imageRetryError);
        }
      }
    } finally {
      if (mounted && widget.url == url) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final decode = ImagePolicy.decodeSize(
        Size(constraints.maxWidth, constraints.maxHeight),
        MediaQuery.devicePixelRatioOf(context),
        scale: widget.resolutionScale,
      );
      _provider = ResizeImage(
        CachedNetworkImageProvider(
          widget.url,
          cacheManager: widget.cacheManager ?? ProductImageCache.instance,
        ),
        width: decode.width.toInt(),
        height: decode.height.toInt(),
        policy: ResizeImagePolicy.fit,
      );
      return Image(
        key: ValueKey((widget.url, _attempt)),
        image: _provider!,
        width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
        height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
        fit: widget.fit,
        filterQuality: FilterQuality.medium,
        semanticLabel: widget.label,
        excludeFromSemantics: widget.decorative,
        frameBuilder: (_, child, frame, synchronous) =>
            synchronous || frame != null
            ? child
            : const AppShimmer(
                child: ShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              ),
        errorBuilder: (context, error, stack) => ColoredBox(
          color: AppColors.paleBlue,
          child: Center(
            child: Semantics(
              label: '${widget.label}. ${context.l10n.imageUnavailable}',
              child: IconButton(
                key: const ValueKey('retry_image'),
                tooltip: context.l10n.retryImage,
                onPressed: _retrying ? null : _retry,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.muted),
              ),
            ),
          ),
        ),
      );
    },
  );
}
