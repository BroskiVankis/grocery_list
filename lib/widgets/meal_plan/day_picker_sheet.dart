import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DayPickerSheet {
  static Future<DateTime?> show({
    required BuildContext context,
    required List<DateTime> days,
    required DateTime currentDay,
    required String Function(DateTime) weekdayLabel,
    required bool Function(DateTime, DateTime) isSameDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppColors.sheetSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
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
                'Choose day',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final day in days)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    weekdayLabel(day),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: isSameDate(day, currentDay)
                      ? const Icon(Icons.check, color: AppColors.brandGreen)
                      : null,
                  onTap: () => Navigator.of(context).pop(day),
                ),
            ],
          ),
        );
      },
    );
  }
}
