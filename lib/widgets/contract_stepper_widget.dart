import 'package:flutter/material.dart';
import 'package:albayan/utils/constants.dart';

/// Reusable Stepper Widget with 2 rows
/// First row: steps 1-6
/// Second row: steps 7-9 (centered)
class ContractStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ContractStepper({
    Key? key,
    required this.currentStep,
    this.totalSteps = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          // First Row (Steps 1-6)
          _buildStepperRow(
            startStep: 1,
            endStep: totalSteps,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperRow({required int startStep, required int endStep}) {
    final stepsInRow = endStep - startStep + 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepsInRow, (index) {
        final stepNumber = startStep + index;
        final isCompleted = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;
        final isLastInRow = index == stepsInRow - 1;

        return Flexible(
          flex: isLastInRow ? 0 : 1, // Last element takes no flex space
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : isCurrent
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                      : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isCurrent
                          ? Colors.white
                          : AppColors.primary.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Dotted Line (except for last step in the row)
              if (!isLastInRow)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: DottedLinePainter(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// Dotted Line Painter
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}