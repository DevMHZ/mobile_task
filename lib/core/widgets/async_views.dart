import 'package:flutter/material.dart';

import '../localization/context_l10n.dart';
import '../network/app_failure.dart';
import '../theme/app_theme.dart';
import 'app_shimmer.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.title,
    required this.message,
    required this.icon,
    this.action,
    super.key,
  });
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpace.xl,
      vertical: AppSpace.xxl,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.xl),
          decoration: const BoxDecoration(
            color: AppColors.paleBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.blue, size: 32),
        ),
        const SizedBox(height: AppSpace.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
        if (action != null) ...[const SizedBox(height: AppSpace.xl), action!],
      ],
    ),
  );
}

class FailureView extends StatelessWidget {
  const FailureView({required this.failure, required this.retry, super.key});
  final AppFailure failure;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => EmptyView(
    title: context.l10n.errorTitle,
    message: context.failureMessage(failure),
    icon: failure.kind == FailureKind.offline
        ? Icons.wifi_off_rounded
        : Icons.cloud_off_rounded,
    action: FilledButton.icon(
      onPressed: retry,
      icon: const Icon(Icons.refresh_rounded),
      label: Text(context.l10n.retry),
    ),
  );
}

class InlineFailure extends StatelessWidget {
  const InlineFailure({required this.failure, required this.retry, super.key});
  final AppFailure failure;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    borderRadius: BorderRadius.circular(AppSpace.controlRadius),
    child: Padding(
      padding: const EdgeInsets.all(AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Text(context.failureMessage(failure))),
          TextButton(onPressed: retry, child: Text(context.l10n.retry)),
        ],
      ),
    ),
  );
}

/// Realistic skeleton reflecting the real-estate property card.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpace.radius),
        boxShadow: const [DesignMetrics.cardShadow],
      ),
      padding: const EdgeInsets.all(AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpace.controlRadius),
                child: const AspectRatio(
                  aspectRatio: DesignMetrics.gridImageRatio,
                  child: ShimmerBox(),
                ),
              ),
              PositionedDirectional(
                top: AppSpace.sm,
                end: AppSpace.sm,
                child: ShimmerBox(
                  width: 44,
                  height: 20,
                  borderRadius: BorderRadius.circular(AppSpace.xl),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          const ShimmerLine(width: 140, height: DesignMetrics.cardTitleSize),
          const SizedBox(height: AppSpace.xs),
          const ShimmerLine(width: 90, height: DesignMetrics.cardTitleSize),
          const SizedBox(height: AppSpace.sm),
          const ShimmerLine(width: 60, height: DesignMetrics.cardCategorySize),
          const SizedBox(height: AppSpace.md),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLine(width: 70, height: 16),
              ShimmerCircle(size: 26),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton reflecting the featured carousel card on discovery.
class FeaturedCardSkeleton extends StatelessWidget {
  const FeaturedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DesignMetrics.featuredWidth,
      height: DesignMetrics.featuredHeight,
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(DesignMetrics.featuredRadius),
      ),
      padding: const EdgeInsets.all(AppSpace.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: ShimmerBox(
              width: 48,
              height: 22,
              borderRadius: BorderRadius.all(Radius.circular(AppSpace.xl)),
            ),
          ),
          Spacer(),
          ShimmerLine(width: 180, height: 20),
          SizedBox(height: AppSpace.xs),
          ShimmerLine(width: 110, height: 20),
          SizedBox(height: AppSpace.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLine(width: 80, height: 16),
              ShimmerCircle(size: 32),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rich, animated discovery/catalog skeleton accurately reflecting the home feed.
class CatalogSkeleton extends StatelessWidget {
  const CatalogSkeleton({this.showFeatured = true, super.key});
  final bool showFeatured;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.loading,
      child: ExcludeSemantics(
        child: AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showFeatured) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.page,
                    vertical: AppSpace.sm,
                  ),
                  child: ShimmerLine(width: 120, height: 18),
                ),
                SizedBox(
                  height: DesignMetrics.featuredHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.page,
                    ),
                    itemCount: 2,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: DesignMetrics.featuredGap),
                    itemBuilder: (_, _) => const FeaturedCardSkeleton(),
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpace.page,
                  vertical: AppSpace.sm,
                ),
                child: ShimmerLine(width: 160, height: 18),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.page),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < AppSpace.gridBreakpoint
                        ? 2
                        : (constraints.maxWidth / 180).floor().clamp(2, 4);
                    const spacing = AppSpace.lg;
                    final width =
                        (constraints.maxWidth - (columns - 1) * spacing) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: List.generate(
                        4,
                        (_) => SizedBox(
                          width: width,
                          child: const ProductCardSkeleton(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Realistic skeleton reflecting the Product Details page layout.
class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                const AspectRatio(
                  aspectRatio: DesignMetrics.detailImageRatio,
                  child: ShimmerBox(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                PositionedDirectional(
                  top: topPadding + AppSpace.sm,
                  start: AppSpace.sm,
                  child: const ShimmerCircle(size: 40),
                ),
                PositionedDirectional(
                  top: topPadding + AppSpace.sm,
                  end: AppSpace.sm,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerCircle(size: 40),
                      SizedBox(width: AppSpace.sm),
                      ShimmerCircle(size: 40),
                    ],
                  ),
                ),
                const PositionedDirectional(
                  bottom: AppSpace.lg,
                  start: 0,
                  end: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShimmerBox(
                        width: 24,
                        height: 6,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      SizedBox(width: 4),
                      ShimmerBox(
                        width: 6,
                        height: 6,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      SizedBox(width: 4),
                      ShimmerBox(
                        width: 6,
                        height: 6,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(width: 240, height: 24),
                  const SizedBox(height: AppSpace.sm),
                  const ShimmerLine(width: 160, height: 24),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      ShimmerBox(
                        width: 80,
                        height: 26,
                        borderRadius: BorderRadius.circular(AppSpace.controlRadius),
                      ),
                      const SizedBox(width: AppSpace.md),
                      ShimmerBox(
                        width: 50,
                        height: 26,
                        borderRadius: BorderRadius.circular(AppSpace.controlRadius),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xl),
                  const ShimmerLine(width: 120, height: 28),
                  const SizedBox(height: AppSpace.xl),
                  Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Container(
                          margin: EdgeInsetsDirectional.only(
                            end: i < 2 ? AppSpace.sm : 0,
                          ),
                          padding: const EdgeInsets.all(AppSpace.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSpace.controlRadius),
                            boxShadow: const [DesignMetrics.cardShadow],
                          ),
                          child: const Column(
                            children: [
                              ShimmerCircle(size: 28),
                              SizedBox(height: AppSpace.sm),
                              ShimmerLine(width: 40, height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  const ShimmerLine(width: 100, height: 18),
                  const SizedBox(height: AppSpace.md),
                  const ShimmerLine(width: double.infinity, height: 14),
                  const SizedBox(height: AppSpace.sm),
                  const ShimmerLine(width: double.infinity, height: 14),
                  const SizedBox(height: AppSpace.sm),
                  const FractionallySizedBox(
                    widthFactor: 0.7,
                    alignment: AlignmentDirectional.centerStart,
                    child: ShimmerLine(width: double.infinity, height: 14),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  ShimmerBox(
                    width: double.infinity,
                    height: 54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Realistic skeleton reflecting the Manage Collection list view.
class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.page),
            child: ShimmerBox(
              width: double.infinity,
              height: 48,
              borderRadius: BorderRadius.circular(AppSpace.controlRadius),
            ),
          ),
          ...List.generate(
            5,
            (_) => const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.page,
                vertical: AppSpace.sm,
              ),
              child: Row(
                children: [
                  ShimmerBox(
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.all(Radius.circular(AppSpace.controlRadius)),
                  ),
                  SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 180, height: 14),
                        SizedBox(height: AppSpace.sm),
                        ShimmerLine(width: 80, height: 12),
                      ],
                    ),
                  ),
                  ShimmerCircle(size: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton reflecting a grid of property cards (e.g. Favorites / Search).
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({this.count = 4, super.key});
  final int count;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.page),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < AppSpace.gridBreakpoint
                ? 2
                : (constraints.maxWidth / 180).floor().clamp(2, 4);
            const spacing = AppSpace.lg;
            final width =
                (constraints.maxWidth - (columns - 1) * spacing) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(
                count,
                (_) => SizedBox(
                  width: width,
                  child: const ProductCardSkeleton(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
