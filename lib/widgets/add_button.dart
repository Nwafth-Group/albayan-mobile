import 'package:albayan/utils/constants.dart';
import 'package:albayan/widgets/custom_icon.dart';
import 'package:flutter/material.dart';

Widget buildServiceOption({
  required BuildContext context,
  required String icon,
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFB3D4D9).withOpacity(0.25)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          ImageAsset(icon),
          const SizedBox(width: 8),

          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20,)
        ],
      ),
    ),
  );
}