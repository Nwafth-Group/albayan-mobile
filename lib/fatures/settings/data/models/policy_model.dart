// ============================================
// FILE: lib/fatures/settings/data/models/policy_model.dart
// ============================================
//
// Parses `GET /public/policies?policy_type=...`'s `data`:
// { "id", "policy_type", "title", "content" (HTML), "created_at" }

enum PolicyType { terms, privacy, financial }

extension PolicyTypeApiValue on PolicyType {
  /// The `policy_type` query value (`in:terms,privacy,financial`).
  String get apiValue => name;
}

class PolicyModel {
  final String id;
  final PolicyType type;
  final String title;

  /// HTML body.
  final String content;

  final DateTime? createdAt;

  const PolicyModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.createdAt,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json, PolicyType type) {
    return PolicyModel(
      id: json['id']?.toString() ?? '',
      type: PolicyType.values.firstWhere(
        (t) => t.apiValue == json['policy_type']?.toString(),
        orElse: () => type,
      ),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
