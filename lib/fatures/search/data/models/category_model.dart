
// ============================================
// FILE: lib/fatures/search/data/models/category_model.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? parentId;
  final String type; // both / article / book
  final int booksCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    required this.type,
    required this.booksCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      parentId: json['parent_id']?.toString(),
      type: json['type']?.toString() ?? '',
      booksCount: _toInt(json['books_count']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class CategoriesListResponse {
  final List<CategoryModel> items;
  final PaginationMeta meta;

  const CategoriesListResponse({required this.items, required this.meta});

  /// Parses the `data` object: `{ "items": [...], "meta": {...} }`.
  factory CategoriesListResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList()
        : <CategoryModel>[];

    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;

    return CategoriesListResponse(items: items, meta: meta);
  }
}
