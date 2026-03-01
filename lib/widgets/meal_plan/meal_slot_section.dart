import 'package:flutter/material.dart';

import '../../models/meal_slot.dart';
import '../../models/recipe_model.dart';
import '../../theme/app_colors.dart';
import 'meal_card.dart';

class MealSlotSection extends StatelessWidget {
  const MealSlotSection({
    super.key,
    required this.day,
    required this.slot,
    required this.label,
    required this.addLabel,
    required this.recipe,
    required this.onAdd,
    required this.onOpen,
    required this.onLongPress,
    required this.onRemove,
    this.showHeader = true,
  });

  final DateTime day;
  final MealSlot slot;
  final String label;
  final String addLabel;
  final RecipeModel? recipe;
  final VoidCallback onAdd;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.92),
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          SizedBox(height: showHeader ? 6 : 0),
          if (recipe == null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onAdd,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.inputBorderSoft),
                  ),
                  child: Text(
                    addLabel,
                    style: TextStyle(
                      color: AppColors.brandGreen.withOpacity(0.92),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          else
            Dismissible(
              key: ValueKey<String>(
                'meal-${day.toIso8601String()}-${slot.name}-${recipe!.id}',
              ),
              direction: DismissDirection.endToStart,
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondary,
                ),
              ),
              onDismissed: (_) => onRemove(),
              child: MealCard(
                recipe: recipe!,
                mealTypeLabel: label,
                onTap: onOpen,
                onLongPress: onLongPress,
              ),
            ),
        ],
      ),
    );
  }
}
