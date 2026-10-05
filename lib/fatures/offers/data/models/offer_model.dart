
// ============================================
// FILE: lib/fatures/offers/data/models/offer_model.dart
// ============================================
//
// Parses `GET /public/offers?type=&search=&page=`:
// { "data": { "urgent_offer": {...}, "items": [...], "meta": {...} } }
// and `GET /public/offers/{offerId}` (see [OfferDetailsModel]).
//
// Note: a list item's `id` is the discounted thing's own id (the package,
// issue, book or article) — NOT an offer id, so it can't be passed to
// `/public/offers/{id}`. Only `urgent_offer.id` is an offer id.

import '../../../authors/data/models/book_model.dart';
import '../../../issues/data/models/pagination_meta.dart';

enum OfferType { package, book, issue, article }

enum OfferDiscountType { percentage, fixed }

num _num(dynamic v) {
  if (v is num) return v;
  return num.tryParse(v?.toString() ?? '') ?? 0;
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toLocal();
}

OfferType offerTypeFromApi(String? value) {
  switch (value) {
    case 'package':
      return OfferType.package;
    case 'issue':
      return OfferType.issue;
    case 'article':
      return OfferType.article;
    case 'book':
    default:
      return OfferType.book;
  }
}

extension OfferTypeApiValue on OfferType {
  /// The `type` query value `GET /public/offers` expects.
  String get apiValue {
    switch (this) {
      case OfferType.package:
        return 'package';
      case OfferType.book:
        return 'book';
      case OfferType.issue:
        return 'issue';
      case OfferType.article:
        return 'article';
    }
  }
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

/// One discounted item from the offers list.
class OfferModel {
  /// The discounted item's own id (package / issue / book / article id).
  final String id;
  final OfferType type;
  final String name;
  final String? image;
  final OfferDiscountType discountType;
  final num discountValue;
  final num oldPrice;
  final num newPrice;

  /// `formatted_end_date` — already formatted and localized by the backend.
  final String endDateLabel;

  /// `extra_info` — per type: package "3 Books", issue "Issue #1", book
  /// the author's name, article its subtitle.
  final String? extraInfo;

  /// True when this is a whole offer campaign opened from
  /// `/public/offers/{offerId}` rather than a single list item — its [id] is
  /// then an offer id, which can't be added to the cart.
  final bool isCampaign;

  const OfferModel({
    required this.id,
    required this.type,
    required this.name,
    required this.image,
    required this.discountType,
    required this.discountValue,
    required this.oldPrice,
    required this.newPrice,
    required this.endDateLabel,
    this.extraInfo,
    this.isCampaign = false,
  });

  bool get isFree => newPrice <= 0;

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id']?.toString() ?? '',
      type: offerTypeFromApi(json['offer_type']?.toString()),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      discountType: json['discount_type'] == 'fixed'
          ? OfferDiscountType.fixed
          : OfferDiscountType.percentage,
      discountValue: _num(json['discount_value']),
      oldPrice: _num(json['price']),
      newPrice: _num(json['final_price'] ?? json['price']),
      endDateLabel: json['formatted_end_date']?.toString() ?? '',
      extraInfo: json['extra_info']?.toString(),
    );
  }
}

/// `urgent_offer` — the offer ending soonest, shown in the list's countdown.
class UrgentOfferModel {
  final String id;
  final String name;
  final DateTime endsAt;

  const UrgentOfferModel({
    required this.id,
    required this.name,
    required this.endsAt,
  });

  static UrgentOfferModel? fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final endsAt = _date(json['end_date']) ??
        // Fall back to the relative countdown if end_date is missing.
        (json['ends_in'] is Map<String, dynamic>
            ? DateTime.now().add(
                Duration(seconds: _int(json['ends_in']['total_seconds'])),
              )
            : null);
    if (endsAt == null) return null;
    return UrgentOfferModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      endsAt: endsAt,
    );
  }
}

class OffersResponse {
  final UrgentOfferModel? urgentOffer;
  final List<OfferModel> items;
  final PaginationMeta meta;

  const OffersResponse({
    required this.urgentOffer,
    required this.items,
    required this.meta,
  });

  factory OffersResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final rawMeta = data['meta'];
    return OffersResponse(
      urgentOffer: UrgentOfferModel.fromJson(data['urgent_offer']),
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(OfferModel.fromJson)
              .toList()
          : const [],
      meta: rawMeta is Map<String, dynamic>
          ? PaginationMeta.fromJson(rawMeta)
          : PaginationMeta.empty,
    );
  }
}

/// The content an offer's details page shows beyond the list item itself,
/// loaded per type (package books, book overview, issue index, ...).
class OfferContent {
  /// Exact end time — only known for a campaign loaded from
  /// `/public/offers/{offerId}`; list items carry just a formatted date.
  final DateTime? endsAt;

  // Package
  final List<BookModel> packageItems;

  // Book / Article
  final String? author;
  final int? pagesCount;
  final double? rate;
  final String? overview;

  // Issue
  final DateTime? publishedAt;
  final String? shortWordTitle;
  final String? shortWordSummary;
  final List<OfferIndexItem> indexItems;

  const OfferContent({
    this.endsAt,
    this.packageItems = const [],
    this.author,
    this.pagesCount,
    this.rate,
    this.overview,
    this.publishedAt,
    this.shortWordTitle,
    this.shortWordSummary,
    this.indexItems = const [],
  });

  /// What the list item alone can fill in when the content request fails:
  /// a book's `extra_info` is its author, an article's is its subtitle.
  factory OfferContent.fallback(OfferModel offer) {
    switch (offer.type) {
      case OfferType.book:
        return OfferContent(author: offer.extraInfo);
      case OfferType.article:
        return OfferContent(overview: offer.extraInfo);
      case OfferType.package:
      case OfferType.issue:
        return const OfferContent();
    }
  }
}

/// `GET /public/offers/{offerId}`.
class OfferDetailsModel {
  final String id;
  final String name;
  final OfferType type;
  final OfferDiscountType discountType;
  final num discountValue;
  final num originalPrice;
  final num discountedPrice;
  final DateTime? endsAt;
  final String endDateLabel;
  final List<BookModel> items;

  const OfferDetailsModel({
    required this.id,
    required this.name,
    required this.type,
    required this.discountType,
    required this.discountValue,
    required this.originalPrice,
    required this.discountedPrice,
    required this.endsAt,
    required this.endDateLabel,
    required this.items,
  });

  factory OfferDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return OfferDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: offerTypeFromApi(json['offer_type']?.toString()),
      discountType: json['discount_type'] == 'fixed'
          ? OfferDiscountType.fixed
          : OfferDiscountType.percentage,
      discountValue: _num(json['discount_value']),
      originalPrice: _num(json['original_price']),
      discountedPrice: _num(json['discounted_price']),
      endsAt: _date(json['end_date']),
      endDateLabel: json['formatted_end_date']?.toString() ?? '',
      // Items here use title/cover/rating rather than the book list's
      // name/image/rate — mapped onto BookModel so the same grid renders them.
      items: rawItems is List
          ? rawItems.whereType<Map<String, dynamic>>().map((i) {
              final id = i['id']?.toString() ?? '';
              return BookModel(
                id: id,
                bookId: id,
                name: i['title']?.toString() ?? '',
                language: '',
                image: i['cover']?.toString(),
                author: i['author']?.toString() ?? '',
                price: _num(i['price']),
                finalPrice: null,
                rate: _num(i['rating']).toDouble(),
                rateCount: _int(i['ratings_count']),
                isFavorite: false,
              );
            }).toList()
          : const [],
    );
  }

  /// The header data the offer screens read, for this whole campaign.
  OfferModel toOffer() => OfferModel(
        id: id,
        type: type,
        name: name,
        image: items.isNotEmpty ? items.first.image : null,
        discountType: discountType,
        discountValue: discountValue,
        oldPrice: originalPrice,
        newPrice: discountedPrice,
        endDateLabel: endDateLabel,
        isCampaign: true,
      );

  OfferContent toContent() => OfferContent(endsAt: endsAt, packageItems: items);
}
