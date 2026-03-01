import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class WeekHeader extends StatelessWidget {
  const WeekHeader({
    super.key,
    required this.weekRangeLabel,
    required this.plannedCount,
    required this.totalMeals,
    required this.labelDirection,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final String weekRangeLabel;
  final int plannedCount;
  final int totalMeals;
  final int labelDirection;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sageTop,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) {
                      final beginOffset = Offset(
                        labelDirection > 0 ? 0.18 : -0.18,
                        0,
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: beginOffset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      weekRangeLabel,
                      key: ValueKey<String>(weekRangeLabel),
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$plannedCount of 7 days planned • $totalMeals meals',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onPreviousWeek,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.brandGreen.withOpacity(0.70),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: onNextWeek,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.brandGreen.withOpacity(0.70),
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
