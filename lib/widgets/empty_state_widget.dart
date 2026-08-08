import 'package:albayan/widgets/custom_button.dart';
import 'package:albayan/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? image;
  final IconData? icon;
  final String message;
  final String? message2;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    this.icon,
    this.image,
    required this.message,
    this.message2,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - (AppDimensions.paddingXLarge * 2))
            .clamp(0.0, double.infinity)
            : 0.0;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (image != null)
                    ImageAsset(
                      image!,
                      height: 220,
                      width: 220,
                    ),
                  if (icon != null)
                    Icon(
                      icon,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                  const SizedBox(height: AppDimensions.paddingxSmall),
                  Text(
                    message,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  if (message2 != null) ...[
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      message2!,
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    )
                  ],
                  if (actionText != null && onAction != null) ...[
                    const SizedBox(height: AppDimensions.paddingLarge),
                    CustomButton(
                      onPressed: onAction,
                      text: actionText!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}