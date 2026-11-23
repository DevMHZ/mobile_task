import 'product.dart';

enum CatalogSort { recommended, priceLow, priceHigh, rating }

final class CatalogQuery {
  const CatalogQuery({
    this.text = '',
    this.category,
    this.propertyTypes = const {},
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.bathrooms,
    this.minBuildingSize,
    this.maxBuildingSize,
    this.sort = CatalogSort.recommended,
  });

  final String text;
  final String? category;
  final Set<String> propertyTypes;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final double? minBuildingSize;
  final double? maxBuildingSize;
  final CatalogSort sort;

  CatalogQuery copyWith({
    String? text,
    String? category,
    bool clearCategory = false,
    Set<String>? propertyTypes,
    double? minPrice,
    bool clearMinPrice = false,
    double? maxPrice,
    bool clearMaxPrice = false,
    int? bedrooms,
    bool clearBedrooms = false,
    int? bathrooms,
    bool clearBathrooms = false,
    double? minBuildingSize,
    bool clearMinBuildingSize = false,
    double? maxBuildingSize,
    bool clearMaxBuildingSize = false,
    CatalogSort? sort,
  }) => CatalogQuery(
    text: text ?? this.text,
    category: clearCategory ? null : (category ?? this.category),
    propertyTypes: propertyTypes ?? this.propertyTypes,
    minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
    maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
    bathrooms: clearBathrooms ? null : (bathrooms ?? this.bathrooms),
    minBuildingSize:
        clearMinBuildingSize ? null : (minBuildingSize ?? this.minBuildingSize),
    maxBuildingSize:
        clearMaxBuildingSize ? null : (maxBuildingSize ?? this.maxBuildingSize),
    sort: sort ?? this.sort,
  );

  List<Product> apply(Iterable<Product> source) {
    final needle = text.trim().toLowerCase();
    final result = source
        .where(
          (p) =>
              (category == null || p.category == category) &&
              (propertyTypes.isEmpty ||
                  propertyTypes.contains(p.propertyType)) &&
              (bedrooms == null || p.bedrooms >= bedrooms!) &&
              (bathrooms == null || p.bathrooms >= bathrooms!) &&
              (minBuildingSize == null ||
                  p.buildingSize >= minBuildingSize!) &&
              (maxBuildingSize == null ||
                  p.buildingSize <= maxBuildingSize!) &&
              (minPrice == null || p.price >= minPrice!) &&
              (maxPrice == null || p.price <= maxPrice!) &&
              (needle.isEmpty ||
                  '${p.title} ${p.description}'.toLowerCase().contains(needle)),
        )
        .toList();
    result.sort((a, b) {
      final order = switch (sort) {
        CatalogSort.priceLow => a.price.compareTo(b.price),
        CatalogSort.priceHigh => b.price.compareTo(a.price),
        CatalogSort.rating => (b.rating ?? -1).compareTo(a.rating ?? -1),
        CatalogSort.recommended => _priority(a).compareTo(_priority(b)),
      };
      return order == 0 ? a.id.compareTo(b.id) : order;
    });
    return List.unmodifiable(result);
  }

  // Furniture first on the discovery surface; all API categories stay available.
  int _priority(Product p) => switch (p.category) {
    'furniture' => 0,
    'home-decoration' => 1,
    _ => 2,
  };
}
