
// ============================================
// FILE: lib/fatures/authors/data/models/book_model.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

class BookModel {
  final String id;
  final String bookId;
  final String name;
  final String language;
  final String? image;
  final String author;
  final num price;
  final num? finalPrice;
  final double rate;
  final int rateCount;
  final bool isFavorite;
  /// Readable PDF (`file_url`) — a sample when [fileType] is `free`, the
  /// full book when `paid` (owned). Null when the book has no file yet.
  final String? fileUrl;
  final String? fileType;

  const BookModel({
    required this.id,
    required this.bookId,
    required this.name,
    required this.language,
    required this.image,
    required this.author,
    required this.price,
    required this.finalPrice,
    required this.rate,
    required this.rateCount,
    required this.isFavorite,
    this.fileUrl,
    this.fileType,
  });

  /// Price the user actually pays.
  num get effectivePrice => finalPrice ?? price;

  bool get hasDiscount =>
      finalPrice != null && finalPrice! < price;

  bool get isFree => effectivePrice <= 0;

  BookModel copyWith({bool? isFavorite}) => BookModel(
        id: id,
        bookId: bookId,
        name: name,
        language: language,
        image: image,
        author: author,
        price: price,
        finalPrice: finalPrice,
        rate: rate,
        rateCount: rateCount,
        isFavorite: isFavorite ?? this.isFavorite,
        fileUrl: fileUrl,
        fileType: fileType,
      );

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      fileUrl: (json['file_url']?.toString().trim().isEmpty ?? true)
          ? null
          : json['file_url'].toString().trim(),
      fileType: json['file_type']?.toString(),
      id: json['id']?.toString() ?? '',
      bookId: json['book_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      image: json['image']?.toString(),
      author: json['author']?.toString() ?? '',
      price: json['price'] is num ? json['price'] as num : 0,
      finalPrice: json['final_price'] is num ? json['final_price'] as num : null,
      rate: (json['rate'] is num)
          ? (json['rate'] as num).toDouble()
          : double.tryParse(json['rate']?.toString() ?? '') ?? 0,
      rateCount: (json['rate_count'] is num)
          ? (json['rate_count'] as num).toInt()
          : int.tryParse(json['rate_count']?.toString() ?? '') ?? 0,
      isFavorite: json['is_favorite'] == true,
    );
  }
}

class BooksResponse {
  final List<BookModel> items;
  final PaginationMeta meta;

  const BooksResponse({required this.items, required this.meta});

  factory BooksResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromJson)
        .toList()
        : <BookModel>[];
    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;
    return BooksResponse(items: items, meta: meta);
  }
}