import 'package:flutter/material.dart';
import 'package:grocery_list/state/units_preference.dart';
import 'package:grocery_list/theme/app_colors.dart';
import 'package:grocery_list/utils/unit_converter.dart';

class IngredientsSection extends StatelessWidget {
  const IngredientsSection({
    super.key,
    required this.ingredients,
    required this.checkedIngredients,
    required this.onToggle,
  });

  final List<String> ingredients;
  final Set<int> checkedIngredients;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final unitsPreference = UnitsPreferenceScope.of(context).preference;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(ingredients.length, (index) {
          final ingredient = ingredients[index];
          final displayIngredient =
              UnitConverter.convertIngredientTextForDisplay(
                ingredient,
                unitsPreference,
              );
          final isChecked = checkedIngredients.contains(index);
          final isLast = index == ingredients.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onToggle(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (_) => onToggle(index),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: isChecked ? 0.62 : 1,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              style:
                                  textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    decoration: isChecked
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ) ??
                                  const TextStyle(color: AppColors.textPrimary),
                              child: Text(displayIngredient),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.textPrimary.withOpacity(0.04),
                ),
            ],
          );
        }),
      ],
    );
  }
}
