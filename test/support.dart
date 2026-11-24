import 'package:mobile_task/features/settings/data/preferences_store.dart';

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mobile_task/features/catalog/data/models/product.dart';
import 'package:mobile_task/features/catalog/data/models/product_category.dart';
import 'package:mobile_task/features/catalog/data/repo/catalog_repository.dart';

Object? fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync());
List<Product> recordedProducts() =>
    ((fixture('products') as Map<String, dynamic>)['products'] as List<dynamic>)
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
List<ProductCategory> recordedCategories() =>
    (fixture('categories') as List<dynamic>)
        .map((p) => ProductCategory.fromJson(p as Map<String, dynamic>))
        .toList();

class MemoryPreferences implements PreferencesStore {
  String? language;
  List<String> saved = [];
  bool fail = false;
  bool failRead = false;
  @override
  Future<String?> locale() async {
    if (failRead) throw StateError("storage read");
    return language;
  }

  @override
  Future<List<String>> favorites() async => saved;
  @override
  Future<void> setLocale(String value) async {
    if (fail) throw StateError('storage');
    language = value;
  }

  @override
  Future<void> setFavorites(List<String> values) async {
    if (fail) throw StateError('storage');
    saved = values;
  }
}

class FixtureRepository implements CatalogRepository {
  FixtureRepository() : items = recordedProducts();
  List<Product> items;
  Object? error;
  int loads = 0;
  @override
  Future<List<Product>> products({bool refresh = false}) async {
    loads++;
    if (error case final e?) throw e;
    return List.unmodifiable(items);
  }

  @override
  Future<List<ProductCategory>> categories() async => recordedCategories();
  @override
  Future<Product> detail(int id, {bool refresh = false}) async =>
      items.firstWhere((p) => p.id == id);
  @override
  Future<Product> save(ProductDraft draft, {int? id}) async {
    if (error case final e?) throw e;
    final p = Product(
      id: id ?? -1,
      title: draft.title,
      description: draft.description,
      category: draft.category,
      price: draft.price,
      thumbnail: draft.imageUrl,
      images: [draft.imageUrl],
    );
    items = [...items.where((p) => p.id != id), p];
    return p;
  }

  @override
  Future<void> delete(int id) async {
    if (error case final e?) throw e;
    items = items.where((p) => p.id != id).toList();
  }
}

class RecordingAdapter implements HttpClientAdapter {
  final calls = <RequestOptions>[];
  Object Function(RequestOptions request)? respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    final data =
        respond?.call(options) ??
        switch (options.path) {
          '/products' => fixture('products'),
          '/products/categories' => fixture('categories'),
          '/products/add' => fixture('created'),
          _ => fixture('detail'),
        };
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> loadAppFonts() async {
  final english = FontLoader('Rubik')
    ..addFont(rootBundle.load('assets/fonts/Rubik.ttf'));
  final arabic = FontLoader('IBMPlexSansArabic');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    arabic.addFont(
      rootBundle.load(
        'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-$weight.ttf',
      ),
    );
  }
  await Future.wait([english.load(), arabic.load()]);
}
