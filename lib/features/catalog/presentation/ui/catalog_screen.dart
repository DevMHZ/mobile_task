import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/context_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_views.dart';
import '../../data/models/catalog_query.dart';
import '../../data/models/product.dart';
import '../../../settings/presentation/cubit/preferences_cubit.dart';
import '../cubit/catalog_cubit.dart';
import 'filter_sheet.dart';
import 'product_details_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/product_collection.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    this.explore = false,
    this.onExplore,
    this.onProfile,
    this.onSearch,
    this.onFilters,
    this.scrollController,
    this.searchFocus,
    super.key,
  });
  final bool explore;
  final VoidCallback? onExplore;
  final VoidCallback? onProfile;
  final VoidCallback? onSearch;
  final VoidCallback? onFilters;
  final ScrollController? scrollController;
  final FocusNode? searchFocus;
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final TextEditingController _search;
  String? _homeCategory;
  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: context.read<CatalogCubit>().state.query.text,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() {
    if (!widget.explore) {
      setState(() => _homeCategory = null);
      return;
    }
    _search.clear();
    context.read<CatalogCubit>().setQuery(const CatalogQuery());
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _search.clear();
    context.read<CatalogCubit>().submitSearch('');
  }

  void _open(Product product) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProductDetailsScreen(id: product.id),
    ),
  );

  @override
  Widget build(BuildContext context) => BlocBuilder<CatalogCubit, CatalogState>(
    builder: (context, state) {
      final results = widget.explore;
      final homeMatches = CatalogQuery(category: _homeCategory)
          .apply(state.products);
      final featured = const CatalogQuery()
          .apply(state.products)
          .take(DesignMetrics.featuredCount)
          .toList();
      return RefreshIndicator(
        onRefresh: () => context.read<CatalogCubit>().load(refresh: true),
        child: CustomScrollView(
          controller: widget.scrollController,
          key: PageStorageKey(widget.explore ? 'explore' : 'discovery'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.page,
                AppSpace.lg,
                AppSpace.page,
                AppSpace.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (results)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.searchTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: widget.onProfile,
                            tooltip: context.l10n.settings,
                            icon: const Icon(Icons.person_outline_rounded),
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.homeTitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  context.l10n.appTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ],
                            ),
                          ),
                          const _QuickLanguageToggle(),
                          const SizedBox(width: AppSpace.xs),
                          IconButton(
                            onPressed: state.refreshing
                                ? null
                                : () => context.read<CatalogCubit>().load(
                                    refresh: true,
                                  ),
                            tooltip: context.l10n.refresh,
                            icon: const Icon(Icons.refresh_rounded, size: 22),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpace.xl),
                    TextField(
                      key: const ValueKey('catalog_search'),
                      controller: _search,
                      readOnly: !widget.explore,
                      focusNode: widget.searchFocus,
                      onTap: widget.explore ? null : widget.onSearch,
                      onChanged: context.read<CatalogCubit>().search,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchHint,
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 22,
                          color: AppColors.muted,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.explore)
                              ValueListenableBuilder(
                                valueListenable: _search,
                                builder: (_, value, _) => value.text.isEmpty
                                    ? const SizedBox.shrink()
                                    : IconButton(
                                        tooltip: context.l10n.clearSearch,
                                        onPressed: _clearSearch,
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                        ),
                                      ),
                              ),
                            IconButton(
                              key: const ValueKey('open_filters'),
                              tooltip: context.l10n.filters,
                              onPressed: state.phase != LoadPhase.ready
                                  ? null
                                  : widget.explore
                                  ? () {
                                      FocusScope.of(context).unfocus();
                                      context.read<CatalogCubit>().submitSearch(
                                        _search.text,
                                      );
                                      showModalBottomSheet<void>(
                                        context: context,
                                        useRootNavigator: true,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => const FilterSheet(),
                                      );
                                    }
                                  : widget.onFilters,
                              icon: const Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state.refreshing) const LinearProgressIndicator(),
                  ],
                ),
              ),
            ),
            if (!results &&
                state.phase == LoadPhase.ready &&
                state.products.isNotEmpty) ...[
              SliverToBoxAdapter(child: _section(context.l10n.featured)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      DesignMetrics.featuredHeight *
                      MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.3),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.page,
                    ),
                    itemCount: featured.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: DesignMetrics.featuredGap),
                    itemBuilder: (_, index) {
                      final p = featured[index];
                      return FeaturedProductCard(
                        product: p,
                        open: () => _open(p),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpace.lg)),
              SliverToBoxAdapter(child: _section(context.l10n.collection)),
            ],
            if (state.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.xl),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.page,
                    ),
                    child: Row(
                      children: [
                        _chip(state, null, context.l10n.all),
                        for (final c in state.categories.where(
                          (c) => [
                            'furniture',
                            'home-decoration',
                            'laptops',
                            'smartphones',
                          ].contains(c.slug),
                        ))
                          _chip(state, c.slug, c.name),
                      ],
                    ),
                  ),
                ),
              ),
            if (results && state.phase == LoadPhase.ready)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpace.page,
                    0,
                    AppSpace.page,
                    AppSpace.xl,
                  ),
                  child: Text(
                    context.l10n.resultCount(state.matches.length),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpace.page,
                0,
                AppSpace.page,
                AppSpace.xl,
              ),
              sliver:
                  results &&
                      state.phase == LoadPhase.ready &&
                      state.matches.isNotEmpty
                  ? SliverMainAxisGroup(
                      slivers: [
                        if (state.failure != null)
                          SliverToBoxAdapter(
                            child: InlineFailure(
                              failure: state.failure!,
                              retry: () => context.read<CatalogCubit>().load(
                                refresh: true,
                              ),
                            ),
                          ),
                        SliverList.builder(
                          itemCount: state.matches.length,
                          itemBuilder: (_, index) {
                            final p = state.matches[index];
                            return ProductListCard(
                              key: ValueKey(p.id),
                              product: p,
                              open: () => _open(p),
                            );
                          },
                        ),
                      ],
                    )
                  : SliverToBoxAdapter(
                      child: _content(state, results, homeMatches),
                    ),
            ),
          ],
        ),
      );
    },
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      AppSpace.page,
      0,
      AppSpace.page,
      0,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(
          onPressed: widget.onExplore,
          child: Text(
            context.l10n.viewAll,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _chip(CatalogState state, String? category, String title) => Padding(
    padding: const EdgeInsetsDirectional.only(end: AppSpace.sm),
    child: ChoiceChip(
      label: Text(title),
      selected:
          (widget.explore ? state.query.category : _homeCategory) == category,
      showCheckmark: false,
      labelStyle: TextStyle(
        color:
            (widget.explore ? state.query.category : _homeCategory) == category
            ? Colors.white
            : AppColors.ink,
        fontSize: 13,
      ),
      shape: const StadiumBorder(),
      onSelected: (_) {
        FocusScope.of(context).unfocus();
        if (!widget.explore) {
          setState(() => _homeCategory = category);
          return;
        }
        context.read<CatalogCubit>().setQuery(
          CatalogQuery(
            text: _search.text,
            category: category,
            minPrice: state.query.minPrice,
            maxPrice: state.query.maxPrice,
            sort: state.query.sort,
          ),
        );
      },
    ),
  );

  Widget _content(CatalogState state, bool results, List<Product> homeMatches) {
    if (state.phase == LoadPhase.loading) return const CatalogSkeleton();
    if (state.phase == LoadPhase.error) {
      return FailureView(
        failure: state.failure!,
        retry: () => context.read<CatalogCubit>().load(),
      );
    }
    return Column(
      children: [
        if (state.failure != null)
          InlineFailure(
            failure: state.failure!,
            retry: () => context.read<CatalogCubit>().load(refresh: true),
          ),
        if ((results ? state.matches : homeMatches).isEmpty)
          EmptyView(
            title: context.l10n.noResults,
            message: context.l10n.noResultsBody,
            icon: Icons.search_off_rounded,
            action: OutlinedButton(
              onPressed: _clear,
              child: Text(context.l10n.clearFilters),
            ),
          )
        else
          ProductCollection(
            products: homeMatches
                .take(DesignMetrics.recommendationCount)
                .toList(),
          ),
      ],
    );
  }
}

class _QuickLanguageToggle extends StatelessWidget {
  const _QuickLanguageToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      buildWhen: (prev, curr) => prev.locale != curr.locale,
      builder: (context, state) {
        final isArabic = state.locale.languageCode == 'ar';
        return IconButton(
          key: const ValueKey('quick_language_toggle'),
          onPressed: () {
            final next = isArabic ? 'en' : 'ar';
            context.read<PreferencesCubit>().selectLocale(next);
          },
          tooltip: isArabic
              ? context.l10n.switchToEnglish
              : context.l10n.switchToArabic,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Text(
              isArabic ? 'EN' : 'عربي',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
          ),
        );
      },
    );
  }
}

