
// ============================================
// FILE: lib/fatures/corners/data/models/corner_model.dart
// ============================================

class CornerModel {
  final String id;
  final String name;
  final String? image;
  final String? header;
  final int articlesCount;

  const CornerModel({
    required this.id,
    required this.name,
    required this.image,
    required this.header,
    required this.articlesCount,
  });

  factory CornerModel.fromJson(Map<String, dynamic> json) {
    return CornerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      header: json['header']?.toString(),
      articlesCount: _toInt(json['articles_count']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  CornerModel copyWith({int? articlesCount}) {
    return CornerModel(
      id: id,
      name: name,
      image: image,
      header: header,
      articlesCount: articlesCount ?? this.articlesCount,
    );
  }
}