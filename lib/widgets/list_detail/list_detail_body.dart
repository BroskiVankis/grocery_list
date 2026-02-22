import 'package:flutter/material.dart';

import '../../models/grocery_models.dart';
import '../../theme/app_colors.dart';
import '../grocery_item_tile.dart';

class ListDetailBody extends StatelessWidget {
  final List<GroceryItem> items;
  final Map<String, List<GroceryItem>> grouped;
  final List<String> categoriesWithItems;
  final void Function(String itemId) onRemoveByItemId;

  const ListDetailBody({
    super.key,
    required this.items,
    required this.grouped,
    required this.categoriesWithItems,
    required this.onRemoveByItemId,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 12),
              child: child,
            ),
          );
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 44,
                  color: AppColors.brandGreen.withOpacity(0.55),
                ),
                const SizedBox(height: 18),
                Text(
                  'No items yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add one.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.74),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      physics: const BouncingScrollPhysics(),
      itemCount: categoriesWithItems.fold<int>(
        0,
        (sum, c) => sum + 1 + grouped[c]!.length,
      ),
      itemBuilder: (context, i) {
        int cursor = 0;
        for (final c in categoriesWithItems) {
          // Header
          if (i == cursor) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              child: Text(
                c,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }
          cursor++;

          // Items in this category
          final list = grouped[c]!;
          final localIndex = i - cursor;
          if (localIndex >= 0 && localIndex < list.length) {
            final item = list[localIndex];
            return GroceryItemTile(
              name: item.name,
              onTapRemove: () => onRemoveByItemId(item.id),
            );
          }
          cursor += list.length;
        }

        return const SizedBox.shrink();
      },
    );
  }
}
