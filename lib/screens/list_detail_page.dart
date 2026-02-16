import 'package:flutter/material.dart';
import '../models/grocery_models.dart';
import '../widgets/grocery_item_tile.dart';
import '../widgets/add_item_sheet.dart';
import '../utils/undo_remove.dart';

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
              widget.list.items.add(GroceryItem(name: text));
            });
            widget.onChanged();
          },
        ),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add one.'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final item = items[index];

                return GroceryItemTile(
                  name: item.name,
                  onTapRemove: () => _removeItemWithUndo(index),
                );
              },
            ),
    );
  }
}
