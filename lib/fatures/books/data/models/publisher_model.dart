
// ============================================
// FILE: lib/fatures/books/data/models/publisher_model.dart
// ============================================

class PublisherModel {
  final String id;
  final String name;
  final String? image;

  const PublisherModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory PublisherModel.fromJson(Map<String, dynamic> json) {
    return PublisherModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}
