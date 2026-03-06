import 'package:flutter/material.dart';
import 'package:grocery_list/theme/app_colors.dart';

class RecipeBottomActionBar extends StatelessWidget {
  const RecipeBottomActionBar({
    super.key,
    required this.onAddToMealPlan,
    required this.onStartCooking,
  });

  final VoidCallback onAddToMealPlan;
  final VoidCallback onStartCooking;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onAddToMealPlan,
                child: const Text('Add to Meal Plan'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.9),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onStartCooking,
                child: const Text('Start Cooking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
