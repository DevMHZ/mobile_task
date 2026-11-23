import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/localization/context_l10n.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_network_image.dart';
import '../../../../../core/widgets/interactive_surface.dart';
import '../../../../settings/presentation/cubit/preferences_cubit.dart';
import '../../../data/models/product.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({required this.id, this.onDark = false, super.key});
  final int id;
  final bool onDark;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PreferencesCubit, PreferencesState, bool>(
        selector: (state) => state.favorites.contains(id),
        builder: (context, saved) {
          final color = saved
              ? AppColors.favorite
              : (onDark ? Colors.white : AppColors.muted);

          return IconButton(
            key: ValueKey('favorite_$id'),
            onPressed: () =>
                context.read<PreferencesCubit>().toggleFavorite(id),
            tooltip: saved ? context.l10n.removeSaved : context.l10n.saveItem,
            isSelected: saved,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
              child: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey<bool>(saved),
                color: color,
                size: 20,
              ),
            ),
          );
        },
      );
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({required this.rating, super.key});
  final double rating;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpace.sm,
      vertical: AppSpace.xs,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpace.xl),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: DesignMetrics.star),
        const SizedBox(width: AppSpace.xs),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.blue,
          ),
        ),
      ],
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.open, super.key});
  final Product product;
  final VoidCallback open;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpace.radius),
      boxShadow: const [DesignMetrics.cardShadow],
    ),
    child: InteractiveSurface(
      onTap: open,
      radius: AppSpace.radius,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpace.controlRadius),
                  child: AspectRatio(
                    aspectRatio: DesignMetrics.gridImageRatio,
                    child: ColoredBox(
                      color: AppColors.paleBlue,
                      child: AppNetworkImage(
                        url: product.coverImage,
                        decorative: true,
                        label: product.title,
                      ),
                    ),
                  ),
                ),
                if (product.rating case final rating?)
                  PositionedDirectional(
                    top: AppSpace.sm,
                    end: AppSpace.sm,
                    child: RatingBadge(rating: rating),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            SizedBox(
              height:
                  MediaQuery.textScalerOf(
                    context,
                  ).scale(DesignMetrics.cardTitleSize) *
                  DesignMetrics.cardLineHeight *
                  2,
              child: Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: DesignMetrics.cardTitleSize,
                  height: DesignMetrics.cardLineHeight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              product.category.replaceAll('-', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: DesignMetrics.cardCategorySize,
                height: DesignMetrics.cardLineHeight,
                color: AppColors.muted,
              ),
            ),
            SizedBox(
              height: DesignMetrics.minimumTapTarget,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.money(product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FavoriteButton(id: product.id),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class FeaturedProductCard extends StatelessWidget {
  const FeaturedProductCard({
    required this.product,
    required this.open,
    super.key,
  });
  final Product product;
  final VoidCallback open;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: DesignMetrics.featuredWidth,
    child: InteractiveSurface(
      onTap: open,
      radius: DesignMetrics.featuredRadius,
      color: AppColors.paleBlue,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xxl),
            child: AppNetworkImage(
              url: product.coverImage,
              decorative: true,
              label: product.title,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE6404040)],
              ),
            ),
          ),
          if (product.rating case final rating?)
            PositionedDirectional(
              top: AppSpace.lg,
              end: AppSpace.lg,
              child: RatingBadge(rating: rating),
            ),
          PositionedDirectional(
            start: AppSpace.lg,
            end: AppSpace.xs,
            bottom: AppSpace.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpace.md),
                  child: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  product.category.replaceAll('-', ' '),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.money(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: FavoriteButton(id: product.id, onDark: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ProductListCard extends StatelessWidget {
  const ProductListCard({required this.product, required this.open, super.key});
  final Product product;
  final VoidCallback open;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpace.lg),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSpace.radius),
      boxShadow: const [DesignMetrics.cardShadow],
    ),
    child: InteractiveSurface(
      onTap: open,
      radius: AppSpace.radius,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: DesignMetrics.listImageSize,
              height: DesignMetrics.listImageSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpace.controlRadius),
                    child: ColoredBox(
                      color: AppColors.paleBlue,
                      child: AppNetworkImage(
                        url: product.thumbnail,
                        decorative: true,
                        label: product.title,
                      ),
                    ),
                  ),
                  if (product.rating case final rating?)
                    PositionedDirectional(
                      top: AppSpace.xs,
                      end: AppSpace.xs,
                      child: RatingBadge(rating: rating),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    product.category.replaceAll('-', ' '),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    context.money(product.price),
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            FavoriteButton(id: product.id),
          ],
        ),
      ),
    ),
  );
}
