import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/product.dart';
import '../product_details_screen.dart';
import 'product_card.dart';

class ProductCollection extends StatelessWidget {
  const ProductCollection({required this.products, super.key});
  final List<Product> products;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final geometry = _GridGeometry.of(context, constraints.maxWidth);
      return Wrap(
        spacing: AppSpace.lg,
        runSpacing: AppSpace.lg,
        children: [
          for (final product in products)
            SizedBox(
              key: ValueKey(product.id),
              width: geometry.width,
              child: _card(context, product),
            ),
        ],
      );
    },
  );
}

/// Saved collections grow independently of the Home preview, so build on demand.
class ProductGridSliver extends StatelessWidget {
  const ProductGridSliver({required this.products, super.key});
  final List<Product> products;
  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final geometry = _GridGeometry.of(context, constraints.crossAxisExtent);
      return SliverGrid.builder(
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: geometry.columns,
          mainAxisExtent: geometry.height,
          mainAxisSpacing: AppSpace.lg,
          crossAxisSpacing: AppSpace.lg,
        ),
        itemBuilder: (_, index) => KeyedSubtree(
          key: ValueKey(products[index].id),
          child: _card(context, products[index]),
        ),
      );
    },
  );
}

Widget _card(BuildContext context, Product product) => ProductCard(
  product: product,
  open: () => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProductDetailsScreen(id: product.id),
    ),
  ),
);

class _GridGeometry {
  const _GridGeometry(this.columns, this.width, this.height);
  final int columns;
  final double width;
  final double height;
  factory _GridGeometry.of(BuildContext context, double available) {
    final scaler = MediaQuery.textScalerOf(context);
    final columns = scaler.scale(1) >= DesignMetrics.largeTextThreshold
        ? 1
        : available < AppSpace.gridBreakpoint
        ? 2
        : math.max(
            2,
            ((available + AppSpace.lg) / (AppSpace.cardMinWidth + AppSpace.lg))
                .floor(),
          );
    final width = (available - (columns - 1) * AppSpace.lg) / columns;
    final height =
        width +
        AppSpace.md +
        AppSpace.xs +
        scaler.scale(DesignMetrics.cardTitleSize) *
            DesignMetrics.cardLineHeight *
            2 +
        scaler.scale(DesignMetrics.cardCategorySize) *
            DesignMetrics.cardLineHeight +
        DesignMetrics.minimumTapTarget;
    return _GridGeometry(columns, width, height);
  }
}
