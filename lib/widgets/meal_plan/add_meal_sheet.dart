import 'package:flutter/material.dart';

import '../../models/recipe_model.dart';
import '../../theme/app_colors.dart';

class AddMealSheet {
  static Future<RecipeModel?> show({
    required BuildContext context,
    required String title,
  }) {
    return showModalBottomSheet<RecipeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheetSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final searchController = TextEditingController();
        String query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = sampleRecipes.where((recipe) {
              if (query.trim().isEmpty) return true;
              final q = query.trim().toLowerCase();
              if (recipe.title.toLowerCase().contains(q)) return true;
              return recipe.ingredients.any(
                (ingredient) => ingredient.toLowerCase().contains(q),
              );
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.sheetHandle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: searchController,
                    onChanged: (value) =>
                        setSheetState(() => query = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.inputBorderSoft,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.brandGreen,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.inputBorder,
                      ),
                      itemBuilder: (context, index) {
                        final recipe = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.brandGreen.withOpacity(0.085),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              recipe.icon,
                              color: AppColors.brandGreen,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            recipe.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '⏱ ${recipe.duration} • ${recipe.difficulty}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () => Navigator.of(sheetContext).pop(recipe),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
