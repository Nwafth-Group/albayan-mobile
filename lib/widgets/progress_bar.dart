import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double value;
  final double total;
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  const CustomProgressBar({
    Key? key,
    required this.value,
    required this.total,
    this.height = 8,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentage = (value / total).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: backgroundColor,
        child: Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: FractionallySizedBox(
            widthFactor: percentage,
            child: Container(
              color: progressColor,
            ),
          ),
        ),
      ),
    );
  }
}