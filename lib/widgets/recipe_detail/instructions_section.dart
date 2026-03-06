import 'package:flutter/material.dart';
import 'package:grocery_list/theme/app_colors.dart';

class InstructionsSection extends StatelessWidget {
  const InstructionsSection({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    required this.onSelectStep,
    required this.stepKeyBuilder,
  });

  final List<String> steps;
  final int currentStepIndex;
  final ValueChanged<int> onSelectStep;
  final Key Function(int index) stepKeyBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final totalSteps = steps.length;
    final currentStepDisplay = totalSteps == 0
        ? 0
        : currentStepIndex.clamp(0, totalSteps - 1) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Step $currentStepDisplay of $totalSteps',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(steps.length, (index) {
          final isSelected = currentStepIndex == index;

          return Padding(
            key: stepKeyBuilder(index),
            padding: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSelectStep(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          steps[index],
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
