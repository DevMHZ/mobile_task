import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/localization/context_l10n.dart';
import '../../../../../core/network/app_failure.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_feedback.dart';
import '../../../../../core/widgets/app_network_image.dart';
import '../../../data/models/product.dart';
import '../../cubit/catalog_cubit.dart';
import '../../cubit/product_details_cubit.dart';
import '../product_form_screen.dart';

/// Premium action popup menu designed for real estate property views.
class ProductActionsMenu extends StatelessWidget {
  const ProductActionsMenu({
    required this.product,
    this.onEdit,
    super.key,
  });

  final Product product;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    buildWhen: (previous, current) => previous.mutating != current.mutating,
    builder: (context, state) => Container(
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
        child: PopupMenuButton<void>(
          key: const ValueKey('item_actions'),
          tooltip: context.l10n.itemActions,
          enabled: !state.mutating,
          position: PopupMenuPosition.under,
          offset: const Offset(0, 10),
          elevation: 12,
          shadowColor: const Color(0x29000000),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          itemBuilder: (context) => [
            // Share action
            PopupMenuItem<void>(
              key: const ValueKey('share_item_action'),
              onTap: () => _share(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      context.l10n.shareItem,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit action
            PopupMenuItem<void>(
              key: const ValueKey('edit_item_action'),
              onTap: () => onEdit != null ? onEdit!() : _edit(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      context.l10n.editItem,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const PopupMenuDivider(height: 1),

            // Delete action (Destructive)
            PopupMenuItem<void>(
              key: const ValueKey('delete_item_action'),
              onTap: () => _confirmDelete(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.destructive,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      context.l10n.deleteItem,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.destructive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _share(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.l10n.itemShared;
    await Clipboard.setData(
      ClipboardData(text: 'https://realestate.demo/property/${product.id}'),
    );
    if (messenger.mounted) {
      AppFeedback.success(messenger, msg);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (changed == true && context.mounted) {
      try {
        await context.read<ProductDetailsCubit>().load();
      } catch (_) {}
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.itemDeleted;
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteProductDialog(product: product),
    );
    if (deleted != true) return;
    if (messenger.mounted) {
      AppFeedback.success(messenger, message);
    }
    if (navigator.mounted && route?.isCurrent == true) navigator.pop();
  }
}

class _DeleteProductDialog extends StatefulWidget {
  const _DeleteProductDialog({required this.product});
  final Product product;
  @override
  State<_DeleteProductDialog> createState() => _DeleteProductDialogState();
}

class _DeleteProductDialogState extends State<_DeleteProductDialog> {
  bool _pending = false;
  AppFailure? _failure;

  Future<void> _delete() async {
    if (_pending) return;
    final catalog = context.read<CatalogCubit>();
    setState(() {
      _pending = true;
      _failure = null;
    });
    final deleted = await catalog.delete(widget.product.id);
    if (!mounted) return;
    setState(() {
      _pending = false;
      _failure = deleted ? null : catalog.state.mutationFailure;
    });
    if (deleted) {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopScope(
      canPop: !_pending,
      child: Dialog(
        key: const ValueKey('delete_confirmation'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.all(AppSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpace.dialogWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Red warning icon badge
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.destructive,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                Semantics(
                  namesRoute: true,
                  child: Text(
                    l.deleteConfirm,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  l.deleteConfirmBody,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(AppSpace.radius),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.md),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpace.controlRadius,
                          ),
                          child: SizedBox.square(
                            dimension: AppSpace.dialogThumbnail,
                            child: AppNetworkImage(
                              url: widget.product.thumbnail,
                              label: widget.product.title,
                              decorative: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Text(
                            widget.product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_failure != null) ...[
                  const SizedBox(height: AppSpace.lg),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      context.failureMessage(_failure!),
                      style: const TextStyle(
                        color: AppColors.destructive,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.xxl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('cancel_delete'),
                        onPressed: _pending
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          minimumSize: const Size(48, 48),
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(l.cancel),
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('confirm_delete'),
                        onPressed: _pending ? null : _delete,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.destructive,
                          disabledForegroundColor: Colors.white,
                          minimumSize: const Size(48, 48),
                          shape: const StadiumBorder(),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(_pending ? l.deleting : l.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
