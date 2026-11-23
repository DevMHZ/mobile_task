import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/context_l10n.dart';
import '../../../../core/localization/price_input.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_views.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../data/models/product.dart';
import '../cubit/catalog_cubit.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({this.product, super.key});
  final Product? product;
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _image;
  String? _category;
  bool _allowExit = false;
  bool _confirmingExit = false;

  bool get _hasChanges =>
      _title.text != (widget.product?.title ?? '') ||
      _description.text != (widget.product?.description ?? '') ||
      _price.text != (widget.product?.price.toString() ?? '') ||
      _image.text != (widget.product?.thumbnail ?? '') ||
      _category != widget.product?.category;

  Future<void> _requestClose() async {
    if (_confirmingExit || context.read<CatalogCubit>().state.mutating) return;
    FocusScope.of(context).unfocus();
    _confirmingExit = true;
    final discard =
        !_hasChanges ||
        await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(context.l10n.discardChangesTitle),
                content: Text(context.l10n.discardChangesBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(context.l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(context.l10n.discardChanges),
                  ),
                ],
              ),
            ) ==
            true;
    _confirmingExit = false;
    if (!mounted || !discard) return;
    setState(() => _allowExit = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.title);
    _description = TextEditingController(text: p?.description);
    _price = TextEditingController(text: p?.price.toString());
    _image = TextEditingController(text: p?.thumbnail);
    _category = p?.category;
    context.read<CatalogCubit>().resetMutationFailure();
  }

  @override
  void dispose() {
    for (final controller in [_title, _description, _price, _image]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    builder: (context, state) {
      final l = context.l10n;
      return PopScope(
        canPop: !state.mutating && (_allowExit || !_hasChanges),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !state.mutating) _requestClose();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: l.back,
              onPressed: state.mutating ? null : _requestClose,
              icon: const BackButtonIcon(),
            ),
            title: Text(widget.product == null ? l.addItem : l.editItem),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpace.formWidth),
              child: Form(
                key: _form,
                onChanged: () => setState(() {}),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpace.page),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpace.lg),
                        decoration: BoxDecoration(
                          color: AppColors.paleBlue,
                          borderRadius: BorderRadius.circular(
                            AppSpace.controlRadius,
                          ),
                        ),
                        child: Text(l.demoNotice),
                      ),
                      const SizedBox(height: AppSpace.xl),
                      TextFormField(
                        key: const ValueKey('item_title'),
                        controller: _title,
                        enabled: !state.mutating,
                        maxLength: AppConfig.maxTitleLength,
                        decoration: InputDecoration(
                          labelText: l.title,
                          counterText: '',
                          suffix: _counter(_title, AppConfig.maxTitleLength),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: AppSpace.lg),
                      TextFormField(
                        key: const ValueKey('item_description'),
                        controller: _description,
                        enabled: !state.mutating,
                        minLines: AppSpace.descriptionMinLines,
                        maxLines: AppSpace.descriptionMaxLines,
                        maxLength: AppConfig.maxDescriptionLength,
                        decoration: InputDecoration(
                          labelText: l.description,
                          counterText: '',
                          suffix: _counter(
                            _description,
                            AppConfig.maxDescriptionLength,
                          ),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: AppSpace.lg),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l.category),
                        items: [
                          for (final c in state.categories)
                            DropdownMenuItem(
                              value: c.slug,
                              child: Text(c.name),
                            ),
                        ],
                        onChanged: state.mutating ? null : (v) => _category = v,
                        validator: (v) => v == null ? l.requiredField : null,
                      ),
                      const SizedBox(height: AppSpace.lg),
                      TextFormField(
                        key: const ValueKey('item_price'),
                        controller: _price,
                        enabled: !state.mutating,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l.price,
                          prefixText: 'USD ',
                        ),
                        validator: (v) =>
                            parsePrice(v!) == null ? l.invalidPrice : null,
                      ),
                      const SizedBox(height: AppSpace.lg),
                      TextFormField(
                        key: const ValueKey('item_image'),
                        controller: _image,
                        enabled: !state.mutating,
                        keyboardType: TextInputType.url,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(labelText: l.imageUrl),
                        validator: (v) {
                          final uri = Uri.tryParse(v!.trim());
                          return uri != null &&
                                  uri.scheme == 'https' &&
                                  uri.host.isNotEmpty &&
                                  uri.userInfo.isEmpty
                              ? null
                              : l.invalidUrl;
                        },
                      ),
                      if (state.mutationFailure != null) ...[
                        const SizedBox(height: AppSpace.lg),
                        InlineFailure(
                          failure: state.mutationFailure!,
                          retry: _save,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SafeArea(
              top: false,
              child: Align(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpace.formWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey('submit_item'),
                        onPressed: state.mutating ? null : _save,
                        child: Text(
                          state.mutating
                              ? l.operationInProgress
                              : l.saveChanges,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _counter(TextEditingController controller, int maximum) =>
      ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) => Text(
          '${value.text.length}/$maximum',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
        ),
      );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? context.l10n.requiredField : null;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final product = await context.read<CatalogCubit>().save(
      ProductDraft(
        title: _title.text.trim(),
        description: _description.text.trim(),
        category: _category!,
        price: parsePrice(_price.text)!,
        imageUrl: _image.text.trim(),
        images: widget.product?.thumbnail == _image.text.trim()
            ? widget.product!.images
            : null,
      ),
      id: widget.product?.id,
    );
    if (product == null || !mounted) return;
    setState(() => _allowExit = true);
    // Allow PopScope to observe completion and the exit grant before closing.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    AppFeedback.success(
      ScaffoldMessenger.of(context),
      context.l10n.changeSaved,
    );
    Navigator.of(context).pop(true);
  }
}
