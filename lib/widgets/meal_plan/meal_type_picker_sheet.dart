import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/meal_slot.dart';
import '../../models/recipe_model.dart';
import '../../theme/app_colors.dart';

class MealTypePickerSheet {
  static Future<MealSlot?> show({
    required BuildContext context,
    required Map<MealSlot, RecipeModel> meals,
    required MealSlot suggested,
    required String Function(MealSlot) labelBuilder,
  }) {
    return showModalBottomSheet<MealSlot>(
      context: context,
      backgroundColor: AppColors.sheetSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.sheetHandle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add meal type',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Where should we add it?',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.inputBorder.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < MealSlot.values.length; i++) ...[
                        (() {
                          final slot = MealSlot.values[i];
                          final isPlanned = meals.containsKey(slot);
                          return _MealTypeOptionRow(
                            label: labelBuilder(slot),
                            enabled: !isPlanned,
                            isSuggested: !isPlanned && slot == suggested,
                            trailingHint: isPlanned ? 'Planned' : null,
                            onTap: isPlanned
                                ? null
                                : () {
                                    HapticFeedback.selectionClick();
                                    Navigator.of(context).pop(slot);
                                  },
                          );
                        })(),
                        if (i != MealSlot.values.length - 1)
                          const Divider(
                            height: 1,
                            color: AppColors.inputBorder,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MealTypeOptionRow extends StatelessWidget {
  const _MealTypeOptionRow({
    required this.label,
    required this.enabled,
    required this.isSuggested,
    required this.onTap,
    this.trailingHint,
  });

  final String label;
  final bool enabled;
  final bool isSuggested;
  final VoidCallback? onTap;
  final String? trailingHint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withOpacity(0.72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isSuggested) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: AppColors.brandGreen.withOpacity(0.92),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Suggested',
                        style: TextStyle(
                          color: AppColors.brandGreen.withOpacity(0.92),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (trailingHint != null)
                Text(
                  trailingHint!,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.78),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              if (enabled) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary.withOpacity(0.45),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
