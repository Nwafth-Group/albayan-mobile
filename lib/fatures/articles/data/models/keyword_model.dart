
// ============================================
// FILE: lib/fatures/articles/data/models/keyword_model.dart
// ============================================

class KeywordModel {
  final String id;
  final String name;

  const KeywordModel({required this.id, required this.name});

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    return KeywordModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}