import 'package:flutter/material.dart';
import '../../models/grocery_models.dart';
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
      return const Center(child: Text('No items yet. Tap + to add one.'));
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
