
// ============================================
// FILE: lib/fatures/corners/data/models/corner_articles_filter.dart
// ============================================

import 'package:equatable/equatable.dart';

class CornerArticlesFilter extends Equatable {
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;
  final int perPage;

  const CornerArticlesFilter({
    this.search,
    this.startDate,
    this.endDate,
    this.perPage = 15,
  });

  bool get hasSearch => search != null && search!.trim().isNotEmpty;
  bool get hasDates => startDate != null || endDate != null;

  CornerArticlesFilter setSearch(String? value) => CornerArticlesFilter(
    search: (value == null || value.trim().isEmpty) ? null : value.trim(),
    startDate: startDate,
    endDate: endDate,
    perPage: perPage,
  );

  CornerArticlesFilter setDates({DateTime? start, DateTime? end}) =>
      CornerArticlesFilter(
        search: search,
        startDate: start,
        endDate: end,
        perPage: perPage,
      );

  CornerArticlesFilter clearDates() => CornerArticlesFilter(
    search: search,
    startDate: null,
    endDate: null,
    perPage: perPage,
  );

  /// Builds query params; null/empty values are omitted.
  Map<String, dynamic> toQuery({required int page}) {
    final map = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (startDate != null) map['start_date'] = _fmt(startDate!);
    if (endDate != null) map['end_date'] = _fmt(endDate!);
    if (hasSearch) map['search'] = search!.trim();
    return map;
  }

  static String _fmt(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  List<Object?> get props => [search, startDate, endDate, perPage];
}