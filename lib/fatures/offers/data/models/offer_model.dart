
// ============================================
// FILE: lib/fatures/offers/data/models/offer_model.dart
// ============================================
//
// NOTE: No backend endpoint for offers has been provided yet. This model
// and the mock data in `offers_mock_data.dart` exist so the UI can be built
// and reviewed now. Once a real `/public/offers` (or similar) endpoint
// exists, replace `offers_mock_data.dart` with a real datasource/cubit that
// parses JSON into this same model shape.

enum OfferType { package, book, issue, article }

/// A single book shown inside a Package offer's "Items Included" grid.
class OfferPackageItem {
  final String id;
  final String? image;
  final String title;
  final String author;
  final num price;
  final double rate;

  const OfferPackageItem({
    required this.id,
    required this.image,
    required this.title,
    required this.author,
    required this.price,
    required this.rate,
  });
}

/// A single row shown inside an Issue offer's "Issue Index" tab.
class OfferIndexItem {
  final String titleAr;
  final String description;
  final String author;
  final String? image;

  const OfferIndexItem({
    required this.titleAr,
    required this.description,
    required this.author,
    required this.image,
  });
}

class OfferModel {
  final String id;
  final OfferType type;
  final String name;
  final String? image;
  final int discountPercent;
  final num oldPrice;
  final num newPrice;
  final DateTime date;
  final DateTime endsAt;

  // Package-only
  final int? booksCount;
  final List<OfferPackageItem> packageItems;

  // Book / Article-only
  final String? author;
  final int? pagesCount;
  final double? rate;
  final String? overview;

  // Issue-only
  final String? shortWordTitle;
  final String? shortWordSummary;
  final List<OfferIndexItem> indexItems;

  const OfferModel({
    required this.id,
    required this.type,
    required this.name,
    required this.image,
    required this.discountPercent,
    required this.oldPrice,
    required this.newPrice,
    required this.date,
    required this.endsAt,
    this.booksCount,
    this.packageItems = const [],
    this.author,
    this.pagesCount,
    this.rate,
    this.overview,
    this.shortWordTitle,
    this.shortWordSummary,
    this.indexItems = const [],
  });

  bool get isFree => newPrice <= 0;
}
