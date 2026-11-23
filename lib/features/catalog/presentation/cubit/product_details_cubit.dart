import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/app_failure.dart';
import '../../data/models/product.dart';
import '../../data/repo/catalog_repository.dart';

sealed class ProductDetailsState {
  const ProductDetailsState();
}

final class DetailsLoading extends ProductDetailsState {
  const DetailsLoading();
}

final class DetailsReady extends ProductDetailsState {
  const DetailsReady(this.product);
  final Product product;
}

final class DetailsRemoved extends ProductDetailsState {
  const DetailsRemoved();
}

final class DetailsError extends ProductDetailsState {
  const DetailsError(this.failure);
  final AppFailure failure;
}

final class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository, this.id)
    : super(const DetailsLoading());
  final CatalogRepository _repository;
  final int id;
  bool _loading = false;

  void synchronize(Product? product) {
    if (isClosed) return;
    emit(product == null ? const DetailsRemoved() : DetailsReady(product));
  }

  Future<void> load({bool refresh = false}) async {
    if (isClosed || _loading) return;
    _loading = true;
    emit(const DetailsLoading());
    try {
      final product = await _repository.detail(id, refresh: refresh);
      if (!isClosed && state is! DetailsRemoved) emit(DetailsReady(product));
    } on Object catch (error) {
      if (!isClosed && state is! DetailsRemoved) {
        emit(DetailsError(AppFailure.from(error)));
      }
    } finally {
      _loading = false;
    }
  }
}
