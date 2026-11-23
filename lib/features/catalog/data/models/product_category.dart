final class ProductCategory {
  const ProductCategory({required this.slug, required this.name});
  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        slug: json['slug'] as String,
        name: json['name'] as String,
      );
  final String slug;
  final String name;
}
