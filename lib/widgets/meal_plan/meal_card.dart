import 'package:flutter/material.dart';

import '../../models/recipe_model.dart';
import '../../theme/app_colors.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onLongPress,
    this.mealTypeLabel,
  });

  final RecipeModel recipe;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String? mealTypeLabel;

  String _subtitleDetail() {
    final mealType = mealTypeLabel?.toLowerCase();
    final difficulty = recipe.difficulty.trim();
    if (mealType == null || difficulty.toLowerCase() != mealType) {
      return difficulty;
    }

    final altTag = recipe.tags.where((tag) => tag.toLowerCase() != mealType);
    if (altTag.isNotEmpty) return altTag.first;

    return '${recipe.servings} servings';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.brandGreen.withOpacity(0.018),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.inputBorder.withOpacity(0.45),
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(recipe.icon, color: AppColors.brandGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (mealTypeLabel != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandGreen.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          mealTypeLabel!,
                          style: TextStyle(
                            color: AppColors.brandGreen.withOpacity(0.95),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      '⏱ ${recipe.duration} • ${_subtitleDetail()}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withOpacity(0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
