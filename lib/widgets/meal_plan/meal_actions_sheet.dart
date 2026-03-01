import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class MealActionsSheet {
  static Future<String?> show({required BuildContext context}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.sheetSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.open_with),
                title: const Text('Move'),
                onTap: () => Navigator.of(context).pop('move'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_repeat),
                title: const Text('Change day'),
                onTap: () => Navigator.of(context).pop('change_day'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove'),
                onTap: () => Navigator.of(context).pop('remove'),
              ),
            ],
          ),
        );
      },
    );
  }
}
