import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/context_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_views.dart';
import '../cubit/catalog_cubit.dart';
import 'product_details_screen.dart';
import 'product_form_screen.dart';

class ManageCollectionScreen extends StatelessWidget {
  const ManageCollectionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.manage)),
    floatingActionButton: BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) => state.phase != LoadPhase.ready
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              key: const ValueKey('add_item'),
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const ProductFormScreen(),
                    ),
                  ),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addItem),
            ),
    ),
    body: BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state.phase == LoadPhase.loading) {
          return const SingleChildScrollView(
            child: ProductListSkeleton(),
          );
        }
        if (state.phase == LoadPhase.error) {
          return FailureView(
            failure: state.failure!,
            retry: () => context.read<CatalogCubit>().load(),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: state.products.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(AppSpace.page),
                child: Text(
                  context.l10n.demoNotice,
                  style: const TextStyle(color: AppColors.muted),
                ),
              );
            }
            final product = state.products[index - 1];
            return ListTile(
              title: Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(context.money(product.price)),
              trailing: IconButton(
                tooltip: context.l10n.editItem,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => ProductFormScreen(product: product),
                      ),
                    ),
              ),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(id: product.id),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
