
// ============================================
// FILE: lib/fatures/issues/data/models/issues_filter.dart
// ============================================

import 'package:equatable/equatable.dart';


class IssuesFilter extends Equatable {
  final int? year;
  final int? issueNumber;
  final DateTime? startDate;
  final DateTime? endDate;
  final int perPage;

  const IssuesFilter({
    this.year,
    this.issueNumber,
    this.startDate,
    this.endDate,
    this.perPage = 15,
  });

  /// True when a date range is set (drives the filter-button indicator).
  bool get hasDateFilter => startDate != null || endDate != null;

  /// True when any filter is applied at all.
  bool get hasActiveFilter =>
      issueNumber != null || hasDateFilter; // year is the page default

  /// Merge-style copy (null keeps the existing value — can't clear).
  IssuesFilter copyWith({
    int? year,
    int? issueNumber,
    DateTime? startDate,
    DateTime? endDate,
    int? perPage,
  }) {
    return IssuesFilter(
      year: year ?? this.year,
      issueNumber: issueNumber ?? this.issueNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      perPage: perPage ?? this.perPage,
    );
  }

  /// Sets the issue number explicitly (pass null to clear). Keeps other filters.
  IssuesFilter setIssueNumber(int? number) => IssuesFilter(
    year: year,
    issueNumber: number,
    startDate: startDate,
    endDate: endDate,
    perPage: perPage,
  );

  /// Sets the date range explicitly (pass null to clear a bound). Keeps others.
  IssuesFilter setDates({DateTime? start, DateTime? end}) => IssuesFilter(
    year: year,
    issueNumber: issueNumber,
    startDate: start,
    endDate: end,
    perPage: perPage,
  );

  /// Clears only the date range.
  IssuesFilter clearDates() => setDates(start: null, end: null);

  /// Builds query params for `/public/issues`. Null values are omitted.
  Map<String, dynamic> toQuery({required int page}) {
    final map = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (year != null) map['year'] = year;
    if (issueNumber != null) map['issue_number'] = issueNumber;
    if (startDate != null) map['start_date'] = _fmt(startDate!);
    if (endDate != null) map['end_date'] = _fmt(endDate!);
    return map;
  }

  static String _fmt(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  List<Object?> get props => [year, issueNumber, startDate, endDate, perPage];
}
