import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A high-performance, elegant shimmer wave effect designed for modern real-estate UI.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    super.key,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final isTesting =
        !kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? const Color(0xFFE9EEF4);
    final highlight = widget.highlightColor ?? const Color(0xFFF8FAFC);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller.value;
            final isRtl = Directionality.of(context) == TextDirection.rtl;
            return LinearGradient(
              begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: progress * 2.0 - 1.0,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// A versatile skeleton placeholder box with rounded corners.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.color,
    super.key,
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE2E8F0),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(AppSpace.controlRadius)),
      ),
    );
  }
}

/// A circular shimmer placeholder.
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({required this.size, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: size,
      height: size,
      shape: BoxShape.circle,
      color: color,
    );
  }
}

/// A rounded line placeholder for text with natural text metrics.
class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    required this.width,
    this.height = 12,
    this.borderRadius = 6,
    this.color,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
      color: color,
    );
  }
}
