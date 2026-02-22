import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/item_emoji.dart';

class GroceryItemTile extends StatelessWidget {
  const GroceryItemTile({
    super.key,
    required this.name,
    required this.onTapRemove,
  });

  final String name;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: ListTile(
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: Text(
              emojiForItem(name),
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}
