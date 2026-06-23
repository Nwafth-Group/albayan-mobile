
// ============================================
// FILE: lib/fatures/issues/data/models/pagination_meta.dart
// ============================================

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  /// Whether there are more pages to fetch.
  bool get hasMore => currentPage < lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return PaginationMeta(
      currentPage: parse(json['current_page']),
      lastPage: parse(json['last_page']),
      perPage: parse(json['per_page']),
      total: parse(json['total']),
      from: parse(json['from']),
      to: parse(json['to']),
    );
  }

  static const PaginationMeta empty = PaginationMeta(
    currentPage: 1,
    lastPage: 1,
    perPage: 15,
    total: 0,
    from: 0,
    to: 0,
  );
}