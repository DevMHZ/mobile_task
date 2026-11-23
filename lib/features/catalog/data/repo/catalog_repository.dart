import '../api/catalog_api_service.dart';
import '../models/product.dart';
import '../models/product_category.dart';

abstract interface class CatalogRepository {
  Future<List<Product>> products({bool refresh = false});
  Future<List<ProductCategory>> categories();
  Future<Product> detail(int id, {bool refresh = false});
  Future<Product> save(ProductDraft draft, {int? id});
  Future<void> delete(int id);
}

final class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository(this._api);
  final CatalogApiService _api;
  List<Product>? _products;
  List<ProductCategory>? _categories;
  Future<List<Product>>? _inFlight;
  Future<List<ProductCategory>>? _categoryRequest;
  final _detailRequests = <int, Future<Product>>{};
  final _details = <int, Product>{};
  final _overrides = <int, Product>{};
  final _deleted = <int>{};
  int _sessionId = 0;

  List<Product> _merge(List<Product> base) => List.unmodifiable([
    for (final p in base)
      if (!_deleted.contains(p.id)) _overrides[p.id] ?? p,
    ..._overrides.values.where((p) => p.isSessionOnly),
  ]);

  @override
  Future<List<Product>> products({bool refresh = false}) async {
    if (!refresh && _products != null) return _merge(_products!);
    final pending = _inFlight ??= _api.products();
    try {
      _products = await pending;
      for (final product in _products!) {
        _details[product.id] = product;
      }
      return _merge(_products!);
    } finally {
      if (identical(_inFlight, pending)) _inFlight = null;
    }
  }

  @override
  Future<List<ProductCategory>> categories() async {
    if (_categories != null) return _categories!;
    final pending = _categoryRequest ??= _api.categories();
    try {
      return _categories = await pending;
    } finally {
      if (identical(_categoryRequest, pending)) _categoryRequest = null;
    }
  }

  @override
  Future<Product> detail(int id, {bool refresh = false}) async {
    if (_deleted.contains(id)) throw StateError('Product was deleted');
    if (_overrides.containsKey(id)) return _overrides[id]!;
    if (!refresh && _details.containsKey(id)) return _details[id]!;
    final pending = _detailRequests.putIfAbsent(id, () => _api.detail(id));
    try {
      final product = await pending;
      if (_deleted.contains(id)) throw StateError('Product was deleted');
      return _details[id] = _overrides[id] ?? product;
    } finally {
      _detailRequests.removeWhere(
        (key, value) => key == id && identical(value, pending),
      );
    }
  }

  @override
  Future<Product> save(ProductDraft draft, {int? id}) async {
    final Product product;
    if (id == null) {
      // DummyJSON reuses its simulated ID. Negative IDs are unique local keys.
      product = (await _api.create(draft)).withId(--_sessionId);
    } else if (id < 0) {
      // A simulated creation has no server resource to PATCH.
      product = Product(
        id: id,
        title: draft.title,
        description: draft.description,
        category: draft.category,
        price: draft.price,
        thumbnail: draft.imageUrl,
        images: draft.images,
      );
    } else {
      product = await _api.update(id, draft);
    }
    _overrides[product.id] = product;
    _details[product.id] = product;
    return product;
  }

  @override
  Future<void> delete(int id) async {
    if (id > 0) await _api.delete(id);
    _deleted.add(id);
    _overrides.remove(id);
    _details.remove(id);
  }
}
