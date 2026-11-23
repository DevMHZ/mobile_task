import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/app_failure.dart';
import '../../data/models/catalog_query.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/repo/catalog_repository.dart';

enum LoadPhase { loading, ready, error }

final class CatalogState {
  CatalogState({
    this.phase = LoadPhase.loading,
    List<Product> products = const [],
    List<ProductCategory> categories = const [],
    this.query = const CatalogQuery(),
    this.visibleLimit = AppConfig.pageSize,
    this.refreshing = false,
    this.failure,
    this.mutationFailure,
    this.mutating = false,
  }) : products = List.unmodifiable(products),
       categories = List.unmodifiable(categories);
  final LoadPhase phase;
  final List<Product> products;
  final List<ProductCategory> categories;
  final CatalogQuery query;
  final int visibleLimit;
  final bool refreshing;
  final bool mutating;
  final AppFailure? failure;
  final AppFailure? mutationFailure;
  late final List<Product> matches = query.apply(products);
  late final List<Product> visible = List.unmodifiable(
    matches.take(visibleLimit),
  );

  CatalogState copyWith({
    LoadPhase? phase,
    List<Product>? products,
    List<ProductCategory>? categories,
    CatalogQuery? query,
    int? visibleLimit,
    bool? refreshing,
    bool? mutating,
    AppFailure? failure,
    AppFailure? mutationFailure,
    bool clearFailure = false,
    bool clearMutationFailure = false,
  }) => CatalogState(
    phase: phase ?? this.phase,
    products: products ?? this.products,
    categories: categories ?? this.categories,
    query: query ?? this.query,
    visibleLimit: visibleLimit ?? this.visibleLimit,
    refreshing: refreshing ?? this.refreshing,
    mutating: mutating ?? this.mutating,
    failure: clearFailure ? null : failure ?? this.failure,
    mutationFailure: clearMutationFailure
        ? null
        : mutationFailure ?? this.mutationFailure,
  );
}

final class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(CatalogState());
  final CatalogRepository _repository;
  Timer? _debounce;
  bool _loading = false;

  Future<void> load({bool refresh = false}) async {
    if (_loading) return;
    _loading = true;
    emit(
      state.copyWith(
        phase: state.products.isEmpty ? LoadPhase.loading : LoadPhase.ready,
        refreshing: state.products.isNotEmpty,
        clearFailure: true,
      ),
    );
    try {
      final results = await Future.wait<Object>([
        _repository.products(refresh: refresh),
        _repository.categories(),
      ]);
      if (!isClosed) {
        emit(
          state.copyWith(
            phase: LoadPhase.ready,
            products: results[0] as List<Product>,
            categories: results[1] as List<ProductCategory>,
            refreshing: false,
            clearFailure: true,
          ),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            phase: state.products.isEmpty ? LoadPhase.error : LoadPhase.ready,
            refreshing: false,
            failure: AppFailure.from(error),
          ),
        );
      }
    } finally {
      _loading = false;
    }
  }

  void search(String text) {
    _debounce?.cancel();
    _debounce = Timer(AppConfig.searchDebounce, () {
      if (!isClosed) submitSearch(text);
    });
  }

  void submitSearch(String text) => setQuery(
    CatalogQuery(
      text: text,
      category: state.query.category,
      minPrice: state.query.minPrice,
      maxPrice: state.query.maxPrice,
      sort: state.query.sort,
    ),
  );

  void setQuery(CatalogQuery query) {
    _debounce?.cancel();
    emit(state.copyWith(query: query, visibleLimit: AppConfig.pageSize));
  }

  void showMore() => emit(
    state.copyWith(visibleLimit: state.visibleLimit + AppConfig.pageSize),
  );

  void resetMutationFailure() =>
      emit(state.copyWith(clearMutationFailure: true));

  Future<Product?> save(ProductDraft draft, {int? id}) async {
    if (state.mutating) return null;
    emit(state.copyWith(mutating: true, clearMutationFailure: true));
    try {
      final product = await _repository.save(draft, id: id);
      final products = await _repository.products();
      if (!isClosed) emit(state.copyWith(products: products, mutating: false));
      return product;
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            mutating: false,
            mutationFailure: AppFailure.from(error),
          ),
        );
      }
      return null;
    }
  }

  Future<bool> delete(int id) async {
    if (state.mutating) return false;
    emit(state.copyWith(mutating: true, clearMutationFailure: true));
    try {
      await _repository.delete(id);
      final products = await _repository.products();
      if (!isClosed) emit(state.copyWith(products: products, mutating: false));
      return true;
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            mutating: false,
            mutationFailure: AppFailure.from(error),
          ),
        );
      }
      return false;
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
