import 'package:mobile_task/core/localization/price_input.dart';
import 'package:mobile_task/core/network/app_failure.dart';
import 'package:mobile_task/features/catalog/data/api/catalog_api_service.dart';
import 'package:mobile_task/features/catalog/data/models/catalog_query.dart';
import 'package:mobile_task/features/catalog/data/models/product.dart';
import 'package:mobile_task/features/catalog/data/repo/catalog_repository.dart';
import 'package:mobile_task/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('parses every real product and rejects missing required fields', () {
    final products = recordedProducts();
    expect(
      products.length,
      (fixture('products') as Map<String, dynamic>)['total'],
    );
    expect(
      products.every((p) => p.title.isNotEmpty && p.images.isNotEmpty),
      isTrue,
    );
    final broken = Map<String, dynamic>.from(fixture('detail') as Map)
      ..remove('price');
    expect(() => Product.fromJson(broken), throwsA(isA<TypeError>()));
    expect(() => products.first.images.add('bad'), throwsUnsupportedError);
    expect(
      Product.fromJson(fixture('created') as Map<String, dynamic>).rating,
      isNull,
    );
  });

  test('combined filters operate on the whole dataset, before pagination', () {
    final items = recordedProducts();
    final result = const CatalogQuery(
      text: 'bed',
      category: 'furniture',
      minPrice: 100,
      maxPrice: 5000,
      sort: CatalogSort.priceHigh,
    ).apply(items);
    expect(result, isNotEmpty);
    expect(
      result.every(
        (p) => p.category == 'furniture' && p.price >= 100 && p.price <= 5000,
      ),
      isTrue,
    );
    expect(
      result.map((p) => p.price).toList(),
      orderedEquals(
        result.map((p) => p.price).toList()..sort((a, b) => b.compareTo(a)),
      ),
    );
    expect(const CatalogQuery(text: 'zzzz-no-product').apply(items), isEmpty);
  });

  test(
    'price input accepts Arabic digits and rejects invalid ranges and exponents',
    () {
      expect(parsePrice('٢٥٫٥٠'), 25.5);
      expect(parsePrice('25.50'), 25.5);
      expect(parsePrice('100000001'), 100000001);
      for (final invalid in ['-1', 'NaN', '1e9', '1.999', '', 'not a price']) {
        expect(parsePrice(invalid), isNull, reason: invalid);
      }
    },
  );

  test(
    'repository deduplicates concurrent loads and preserves mutation overlay on refresh',
    () async {
      final adapter = RecordingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final repo = RemoteCatalogRepository(CatalogApiService(dio));
      await Future.wait([repo.products(), repo.products()]);
      expect(adapter.calls.where((c) => c.path == '/products').length, 1);
      await repo.products();
      expect(adapter.calls.length, 1);
      final draft = ProductDraft(
        title: 'Assessment fixture',
        description: 'Description',
        category: 'furniture',
        price: 25,
        imageUrl: 'https://example.com/image.webp',
      );
      final first = await repo.save(draft);
      final second = await repo.save(draft);
      expect(first.id, isNegative);
      expect(first.id, isNot(second.id));
      final afterRefresh = await repo.products(refresh: true);
      expect(afterRefresh.where((p) => p.id < 0).length, 2);
      final calls = adapter.calls.length;
      await repo.save(draft, id: first.id);
      await repo.delete(first.id);
      expect(
        adapter.calls.length,
        calls,
        reason: 'Session resources have no server endpoint',
      );
      expect((await repo.products()).any((p) => p.id == first.id), isFalse);
      dio.close();
    },
  );

  test(
    'API rejects a truncated response instead of silently filtering a partial page',
    () async {
      final adapter = RecordingAdapter()
        ..respond = (_) => {
          'products': [fixture('detail')],
          'total': 194,
          'skip': 0,
        };
      final dio = Dio()..httpClientAdapter = adapter;
      expect(CatalogApiService(dio).products(), throwsFormatException);
      dio.close();
    },
  );

  test(
    'load failure, retry and failed refresh keep meaningful states',
    () async {
      final repo = FixtureRepository()
        ..error = const AppFailure(FailureKind.offline);
      final cubit = CatalogCubit(repo);
      await cubit.load();
      expect(cubit.state.phase, LoadPhase.error);
      repo.error = null;
      await cubit.load();
      expect(cubit.state.phase, LoadPhase.ready);
      final count = cubit.state.products.length;
      repo.error = const AppFailure(FailureKind.timeout);
      await cubit.load(refresh: true);
      expect(cubit.state.products.length, count);
      expect(cubit.state.failure?.kind, FailureKind.timeout);
      await cubit.close();
    },
  );

  test(
    'debounced search uses latest text and close cancels pending work',
    () async {
      final cubit = CatalogCubit(FixtureRepository());
      await cubit.load();
      cubit.search('old query');
      cubit.search('bed');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(cubit.state.query.text, 'bed');
      expect(cubit.state.matches, isNotEmpty);
      cubit.search('pending');
      await cubit.close();
    },
  );

  test(
    'error mapping preserves connection, timeout, HTTP and parsing failures',
    () {
      final request = RequestOptions(path: '/products');
      for (final pair in [
        (DioExceptionType.connectionError, FailureKind.offline),
        (DioExceptionType.receiveTimeout, FailureKind.timeout),
        (DioExceptionType.badResponse, FailureKind.server),
        (DioExceptionType.cancel, FailureKind.cancelled),
      ]) {
        expect(
          AppFailure.from(
            DioException(requestOptions: request, type: pair.$1),
          ).kind,
          pair.$2,
        );
      }
      expect(
        AppFailure.from(const FormatException()).kind,
        FailureKind.invalidResponse,
      );
    },
  );
  test(
    'mutation errors do not replace catalog errors or change existing data',
    () async {
      final repo = FixtureRepository();
      final cubit = CatalogCubit(repo);
      await cubit.load();
      final count = cubit.state.products.length;
      repo.error = const AppFailure(FailureKind.offline);
      final draft = ProductDraft(
        title: 'Unsent item',
        description: 'Description',
        category: 'furniture',
        price: 25,
        imageUrl: 'https://example.com/image.webp',
      );
      expect(await cubit.save(draft), isNull);
      expect(cubit.state.products.length, count);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.mutationFailure?.kind, FailureKind.offline);
      await cubit.load(refresh: true);
      cubit.setQuery(const CatalogQuery(text: 'bed'));
      expect(cubit.state.failure?.kind, FailureKind.offline);
      await cubit.close();
    },
  );
}
