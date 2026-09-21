
// ============================================
// FILE: lib/fatures/search/data/models/advanced_search_filter.dart
// ============================================
//
// Builds the query for `GET /public/search`:
// ?q=&authors[]=&from_date=&to_date=&content_types[]=&price_from=&price_to=
// &is_free=&categories[]=&corners[]=&languages[]=&min_rating=&keyword_id=

import 'package:equatable/equatable.dart';

class AdvancedSearchFilter extends Equatable {
  final String query;
  final Set<String> authorIds;
  final DateTime? fromDate;
  final DateTime? toDate;

  /// One of 'articles' / 'books' / 'issues'.
  final String contentType;
  final double? priceFrom;
  final double? priceTo;
  final bool? isFree;
  final String? categoryId;
  final String? cornerId;
  final String? languageCode;
  final double? minRating;
  final String? keywordId;

  const AdvancedSearchFilter({
    this.query = '',
    this.authorIds = const {},
    this.fromDate,
    this.toDate,
    this.contentType = 'articles',
    this.priceFrom,
    this.priceTo,
    this.isFree,
    this.categoryId,
    this.cornerId,
    this.languageCode,
    this.minRating,
    this.keywordId,
  });

  AdvancedSearchFilter copyWith({
    String? query,
    Set<String>? authorIds,
    DateTime? fromDate,
    DateTime? toDate,
    String? contentType,
    double? priceFrom,
    double? priceTo,
    bool? isFree,
    String? categoryId,
    String? cornerId,
    String? languageCode,
    double? minRating,
    String? keywordId,
  }) {
    return AdvancedSearchFilter(
      query: query ?? this.query,
      authorIds: authorIds ?? this.authorIds,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      contentType: contentType ?? this.contentType,
      priceFrom: priceFrom ?? this.priceFrom,
      priceTo: priceTo ?? this.priceTo,
      isFree: isFree ?? this.isFree,
      categoryId: categoryId ?? this.categoryId,
      cornerId: cornerId ?? this.cornerId,
      languageCode: languageCode ?? this.languageCode,
      minRating: minRating ?? this.minRating,
      keywordId: keywordId ?? this.keywordId,
    );
  }

  Map<String, dynamic> toQuery({required int page}) {
    final map = <String, dynamic>{
      'page': page,
      'content_types[]': [contentType],
    };
    if (query.trim().isNotEmpty) map['q'] = query.trim();
    if (authorIds.isNotEmpty) map['authors[]'] = authorIds.toList();
    if (fromDate != null) map['from_date'] = _fmtDate(fromDate!);
    if (toDate != null) map['to_date'] = _fmtDate(toDate!);
    if (priceFrom != null) map['price_from'] = priceFrom;
    if (priceTo != null) map['price_to'] = priceTo;
    if (isFree != null) map['is_free'] = isFree;
    if (categoryId != null) map['categories[]'] = [categoryId];
    if (cornerId != null) map['corners[]'] = [cornerId];
    if (languageCode != null) map['languages[]'] = [languageCode];
    if (minRating != null) map['min_rating'] = minRating;
    if (keywordId != null) map['keyword_id'] = keywordId;
    return map;
  }

  static String _fmtDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  List<Object?> get props => [
        query,
        authorIds,
        fromDate,
        toDate,
        contentType,
        priceFrom,
        priceTo,
        isFree,
        categoryId,
        cornerId,
        languageCode,
        minRating,
        keywordId,
      ];
}
