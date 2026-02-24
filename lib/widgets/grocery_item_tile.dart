import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/item_emoji.dart';

class GroceryItemTile extends StatelessWidget {
  const GroceryItemTile({
    super.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.onTapRemove,
  });

  final String name;
  final int quantity;
  final String unit;
  final VoidCallback onTapRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTapRemove,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.brandGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.inputBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '$quantity $unit',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreen.withOpacity(0.80),
              ),
            ),
            trailing: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                emojiForItem(name),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
