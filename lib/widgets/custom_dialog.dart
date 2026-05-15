import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CustomStatusDialog extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  // Primary Button (Required)
  final String primaryButtonText;
  final Color color;
  final VoidCallback primaryButtonOnTap;

  // Secondary Button (Optional)
  final String? secondaryButtonText;
  final VoidCallback? secondaryButtonOnTap;

  const CustomStatusDialog({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    required this.primaryButtonOnTap,
    this.secondaryButtonText,
    this.color = AppColors.primary,
    this.secondaryButtonOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0), // Rounded corners like image
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          children: [
            // 1. Image
            Image.asset(
              imagePath,
              height: 120, // Adjust height based on your asset resolution
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // 2. Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight, // Using the darker black color
              ),
            ),

            const SizedBox(height: 12),

            // 3. Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5, // Line height for readability
                color: AppColors.textPrimary, // Using the dark grey color
              ),
            ),

            const SizedBox(height: 32),

            // 4. Primary Button (Required)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: primaryButtonOnTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Pill shape
                  ),
                ),
                child: Text(
                  primaryButtonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 5. Secondary Button (Optional - Only shows if text provided)
            if (secondaryButtonText != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: secondaryButtonOnTap ?? () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: Colors.black)
                    ),
                  ),
                  child: Text(
                    secondaryButtonText!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}