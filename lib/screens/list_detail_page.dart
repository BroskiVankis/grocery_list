import 'package:flutter/material.dart';
import '../models/grocery_models.dart';
import '../widgets/grocery_item_tile.dart';
import '../widgets/add_item_sheet.dart';
import '../utils/undo_remove.dart';
import '../utils/group_items.dart';
import '../utils/item_category.dart';

class ListDetailPage extends StatefulWidget {
  const ListDetailPage({
    super.key,
    required this.list,
    required this.onChanged,
  });

  final GroceryListModel list;
  final VoidCallback onChanged; // tells HomePage to refresh

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  final UndoRemove<GroceryItem> _undo = UndoRemove<GroceryItem>();

  void _removeItemWithUndo(int index) {
    _undo.removeWithUndo(
      context: context,
      list: widget.list.items,
      index: index,
      label: widget.list.items[index].name,
      onChanged: () {
        setState(() {});
        widget.onChanged();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.list.items;
    final itemCount = items.length;
    final subtitle = itemCount == 1 ? '1 item' : '$itemCount items';

    final groupedResult = groupItemsByCategory(items);
    final grouped = groupedResult.grouped;
    final categoriesWithItems = groupedResult.categoriesWithItems;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.list.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.list.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
            onPressed: () {
              setState(() {
                widget.list.isFavorite = !widget.list.isFavorite;
              });
              widget.onChanged();
            },
            icon: Icon(
              widget.list.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddItemSheet(
          context: context,
          onAdd: (text) {
            setState(() {
              widget.list.items.add(
                GroceryItem(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: text,
                  category: categoryForItem(text),
                ),
              );
            });
            widget.onChanged();
          },
        ),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add one.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              physics: const BouncingScrollPhysics(),
              itemCount: categoriesWithItems.fold<int>(
                0,
                (sum, c) => sum + 1 + grouped[c]!.length,
              ),
              itemBuilder: (context, i) {
                // Flattened layout: [Header, item, item, Header, item, ...]
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
                    final realIndex = widget.list.items.indexWhere(
                      (e) => e.id == item.id,
                    );

                    return GroceryItemTile(
                      name: item.name,
                      onTapRemove: () {
                        if (realIndex != -1) _removeItemWithUndo(realIndex);
                      },
                    );
                  }
                  cursor += list.length;
                }

                return const SizedBox.shrink();
              },
            ),
    );
  }
}
