
// ============================================
// FILE: lib/fatures/articles/screens/widgets/star_row.dart
// ============================================

import 'package:flutter/material.dart';

class StarRow extends StatelessWidget {
  final double rating;
  final int total;
  final double size;
  const StarRow({
    super.key,
    required this.rating,
    this.total = 5,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        IconData icon;
        if (i < rating.floor()) {
          icon = Icons.star;
        } else if (i < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: Colors.amber, size: size);
      }),
    );
  }
}