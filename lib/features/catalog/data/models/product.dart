import 'package:flutter/foundation.dart';

@immutable
final class Product {
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.thumbnail,
    required List<String> images,
    this.rating,
  }) : images = List.unmodifiable(images);

  factory Product.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num).toDouble();
    final rating = (json['rating'] as num?)?.toDouble();
    if (!price.isFinite || price < 0 || (rating != null && !rating.isFinite)) {
      throw const FormatException('Invalid product numeric value');
    }
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: price,
      thumbnail: json['thumbnail'] as String,
      images: (json['images'] as List<dynamic>).cast<String>(),
      rating: rating,
    );
  }

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String thumbnail;
  final List<String> images;
  final double? rating;
  String get coverImage => images.isEmpty ? thumbnail : images.first;
  bool get isSessionOnly => id < 0;

  int get bedrooms => (id.abs() % 4) + 1;
  int get bathrooms => (id.abs() % 3) + 1;
  int get buildingSize => 800 + ((id.abs() * 190) % 2400);
  String get propertyType => switch (id.abs() % 6) {
    0 => 'Apartments',
    1 => 'Townhomes',
    2 => 'Homes',
    3 => 'Condos',
    4 => 'Duplexes',
    _ => 'Studios',
  };

  Product withId(int value) => Product(
    id: value,
    title: title,
    description: description,
    category: category,
    price: price,
    thumbnail: thumbnail,
    images: images,
    rating: rating,
  );
}

@immutable
final class ProductDraft {
  ProductDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    List<String>? images,
  }) : images = List.unmodifiable(images ?? [imageUrl]);
  final String title;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final List<String> images;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'thumbnail': imageUrl,
    'images': images,
  };
}
