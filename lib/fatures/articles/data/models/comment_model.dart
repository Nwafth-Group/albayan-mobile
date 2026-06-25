
// ============================================
// FILE: lib/fatures/articles/data/models/comment_model.dart
// ============================================

import 'package:albayan/fatures/issues/data/models/pagination_meta.dart';

class CommentModel {
  final String id;
  final String userName;
  final String? userImage;
  final double rating;
  final String commentText;
  final DateTime? submittedDate;

  const CommentModel({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.commentText,
    required this.submittedDate,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      userImage: json['user_image']?.toString(),
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      commentText: json['comment_text']?.toString() ?? '',
      submittedDate: json['submitted_date'] == null
          ? null
          : DateTime.tryParse(json['submitted_date'].toString()),
    );
  }
}

class CommentsResponse {
  final List<CommentModel> items;
  final PaginationMeta meta;

  const CommentsResponse({required this.items, required this.meta});

  factory CommentsResponse.fromData(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = (rawItems is List)
        ? rawItems
        .whereType<Map<String, dynamic>>()
        .map(CommentModel.fromJson)
        .toList()
        : <CommentModel>[];
    final rawMeta = data['meta'];
    final meta = (rawMeta is Map<String, dynamic>)
        ? PaginationMeta.fromJson(rawMeta)
        : PaginationMeta.empty;
    return CommentsResponse(items: items, meta: meta);
  }
}