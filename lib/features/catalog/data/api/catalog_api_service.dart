import 'package:dio/dio.dart';

import '../models/product.dart';
import '../models/product_category.dart';

class CatalogApiService {
  CatalogApiService(this._dio);
  final Dio _dio;

  Future<List<Product>> products() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'limit': 0},
    );
    final json = response.data!;
    final products = (json['products'] as List<dynamic>)
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
    if (products.length != (json['total'] as int) ||
        (json['skip'] as int) != 0 ||
        products.map((p) => p.id).toSet().length != products.length) {
      throw const FormatException('Incomplete catalog response');
    }
    return List.unmodifiable(products);
  }

  Future<List<ProductCategory>> categories() async {
    final response = await _dio.get<List<dynamic>>('/products/categories');
    return List.unmodifiable(
      response.data!.map(
        (p) => ProductCategory.fromJson(p as Map<String, dynamic>),
      ),
    );
  }

  Future<Product> detail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    final product = Product.fromJson(response.data!);
    if (product.id != id) throw const FormatException('Unexpected product ID');
    return product;
  }

  Future<Product> create(ProductDraft draft) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/products/add',
      data: draft.toJson(),
    );
    return Product.fromJson(response.data!);
  }

  Future<Product> update(int id, ProductDraft draft) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/products/$id',
      data: draft.toJson(),
    );
    final product = Product.fromJson(response.data!);
    if (product.id != id) {
      throw const FormatException('Unexpected updated product ID');
    }
    return product;
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete<Map<String, dynamic>>('/products/$id');
    if (response.data!['id'] != id || response.data!['isDeleted'] != true) {
      throw const FormatException('Unexpected deletion response');
    }
  }
}
