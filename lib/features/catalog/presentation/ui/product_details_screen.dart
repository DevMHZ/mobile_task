import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/context_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/interactive_surface.dart';
import '../../../../core/widgets/async_views.dart';
import '../../data/models/product.dart';
import '../../data/repo/catalog_repository.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/product_details_cubit.dart';
import 'product_form_screen.dart';
import 'product_gallery_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/product_actions_menu.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({required this.id, super.key});
  final int id;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        ProductDetailsCubit(context.read<CatalogRepository>(), id)..load(),
    child: BlocListener<CatalogCubit, CatalogState>(
      listenWhen: (previous, current) =>
          _find(previous.products, id) != _find(current.products, id),
      listener: (context, state) => context
          .read<ProductDetailsCubit>()
          .synchronize(_find(state.products, id)),
      child: const _DetailsView(),
    ),
  );
}

Product? _find(List<Product> products, int id) {
  for (final product in products) {
    if (product.id == id) return product;
  }
  return null;
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) => Scaffold(
          appBar: state is DetailsReady
              ? null
              : AppBar(title: Text(context.l10n.details)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpace.maxWidth),
              child: switch (state) {
                DetailsLoading() => const ProductDetailsSkeleton(),
                DetailsError(:final failure) => SingleChildScrollView(
                  child: FailureView(
                    failure: failure,
                    retry: () =>
                        context.read<ProductDetailsCubit>().load(refresh: true),
                  ),
                ),
                DetailsRemoved() => EmptyView(
                  title: context.l10n.itemUnavailable,
                  message: context.l10n.itemRemovedBody,
                  icon: Icons.inventory_2_outlined,
                ),
                DetailsReady(:final product) => Stack(
                  fit: StackFit.expand,
                  children: [
                    _DetailsContent(product: product),
                    PositionedDirectional(
                      top: MediaQuery.paddingOf(context).top + AppSpace.sm,
                      end: AppSpace.sm,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: FavoriteButton(id: product.id),
                            ),
                          ),
                          const SizedBox(width: AppSpace.sm),
                          ProductActionsMenu(
                            key: const ValueKey('product_actions_menu'),
                            product: product,
                          ),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      top: MediaQuery.paddingOf(context).top + AppSpace.sm,
                      start: AppSpace.sm,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Material(
                          color: Colors.transparent,
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: BackButton(),
                        ),
                      ),
                    ),
                  ],
                ),
              },
            ),
          ),
        ),
      );
}

class _DetailsContent extends StatefulWidget {
  const _DetailsContent({required this.product});
  final Product product;
  @override
  State<_DetailsContent> createState() => _DetailsContentState();
}

class _DetailsContentState extends State<_DetailsContent> {
  int _page = 0;
  @override
  void didUpdateWidget(covariant _DetailsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.product.images, widget.product.images)) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final l = context.l10n;
    final images = p.images.isEmpty ? [p.thumbnail] : p.images;
    Future<void> edit() async {
      final changed = await Navigator.of(context, rootNavigator: true)
          .push<bool>(
            MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)),
          );
      if (changed == true && context.mounted) {
        await context.read<ProductDetailsCubit>().load();
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: DesignMetrics.detailImageRatio,
                      child: ColoredBox(
                        color: AppColors.paleBlue,
                        child: PageView.builder(
                          key: ValueKey(p.thumbnail),
                          itemCount: images.length,
                          onPageChanged: (index) =>
                              setState(() => _page = index),
                          itemBuilder: (_, index) => AppNetworkImage(
                            url: images[index],
                            label: p.title,
                          ),
                        ),
                      ),
                    ),
                    if (images.length > 1)
                      PositionedDirectional(
                        bottom: AppSpace.lg,
                        start: 0,
                        end: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < images.length; i++)
                              Semantics(
                                label: '${i + 1} / ${images.length}',
                                selected: i == _page,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpace.xs / 2,
                                  ),
                                  width: i == _page
                                      ? DesignMetrics.activeDotWidth
                                      : DesignMetrics.dotSize,
                                  height: DesignMetrics.dotSize,
                                  decoration: BoxDecoration(
                                    color: i == _page
                                        ? AppColors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppSpace.sm,
                                    ),
                                  ),
                                ),
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
                      Text(
                        p.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpace.md),
                      Wrap(
                        spacing: AppSpace.md,
                        runSpacing: AppSpace.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.sm,
                              vertical: AppSpace.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.paleBlue,
                              borderRadius: BorderRadius.circular(
                                AppSpace.controlRadius,
                              ),
                            ),
                            child: Text(
                              p.category.replaceAll('-', ' ').toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (p.rating case final rating?)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: DesignMetrics.star,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpace.xs),
                                Text(rating.toStringAsFixed(1)),
                              ],
                            )
                          else
                            Text(l.noRating),
                        ],
                      ),
                      const SizedBox(height: AppSpace.xl),
                      const Divider(),
                      const SizedBox(height: AppSpace.lg),
                      Text(
                        l.aboutItem,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpace.md),
                      Text(
                        p.description,
                        style: const TextStyle(
                          color: AppColors.muted,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xl),
                      Text(
                        l.gallery,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpace.lg),
                      SizedBox(
                        height: DesignMetrics.listImageSize,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpace.md),
                          itemBuilder: (_, index) => SizedBox(
                            width: DesignMetrics.listImageSize,
                            child: InteractiveSurface(
                              radius: AppSpace.controlRadius,
                              color: AppColors.paleBlue,
                              key: ValueKey('gallery_thumbnail_$index'),
                              onTap: () =>
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ProductGalleryScreen(
                                        images: images,
                                        title: p.title,
                                        initialPage: index,
                                      ),
                                    ),
                                  ),
                              child: AppNetworkImage(
                                url: images[index],
                                label: p.title,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.page),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.price,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          context.money(p.price),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  FilledButton.icon(
                    onPressed: edit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l.editItem),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
