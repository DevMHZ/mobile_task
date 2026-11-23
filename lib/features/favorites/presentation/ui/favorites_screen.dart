import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/context_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_views.dart';
import '../../../catalog/presentation/cubit/catalog_cubit.dart';
import '../../../catalog/presentation/ui/widgets/product_collection.dart';
import '../../../settings/presentation/cubit/preferences_cubit.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({required this.explore, super.key});
  final VoidCallback explore;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PreferencesCubit, PreferencesState>(
        buildWhen: (prev, curr) => prev.favorites != curr.favorites,
        builder: (context, preferences) =>
            BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, catalog) {
                final saved = catalog.products
                    .where((p) => preferences.favorites.contains(p.id))
                    .toList();
                return CustomScrollView(
                  key: const PageStorageKey('favorites'),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpace.page),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (catalog.phase == LoadPhase.loading)
                              const ProductGridSkeleton()
                            else if (catalog.phase == LoadPhase.error)
                              FailureView(
                                failure: catalog.failure!,
                                retry: () =>
                                    context.read<CatalogCubit>().load(),
                              )
                            else if (saved.isEmpty)
                              EmptyView(
                                title: context.l10n.emptySaved,
                                message: context.l10n.emptySavedBody,
                                icon: Icons.favorite_border_rounded,
                                action: FilledButton(
                                  onPressed: explore,
                                  child: Text(context.l10n.explore),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (catalog.phase == LoadPhase.ready && saved.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpace.page,
                          0,
                          AppSpace.page,
                          AppSpace.page,
                        ),
                        sliver: ProductGridSliver(products: saved),
                      ),
                  ],
                );
              },
            ),
      );
}
