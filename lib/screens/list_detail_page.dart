import 'package:flutter/material.dart';

import '../models/grocery_models.dart';
import '../utils/group_items.dart';
import '../utils/item_category.dart';
import '../utils/undo_remove.dart';
import '../widgets/sheets/add_item_sheet.dart';
import '../widgets/list_detail/list_detail_app_bar.dart';
import '../widgets/list_detail/list_detail_body.dart';

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

  Future<void> _renameList() async {
    final controller = TextEditingController(text: widget.list.name);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Rename list'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'List name'),
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final newName = (result ?? '').trim();
    if (newName.isEmpty) return;

    setState(() {
      widget.list.name = newName;
    });
    widget.onChanged();
  }

  Future<void> _deleteList() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Delete list?'),
          content: const Text('This will remove the list and all its items.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!mounted) return;

    // Let HomePage remove this list
    Navigator.of(context).pop('delete');
  }

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
      appBar: ListDetailAppBar(
        title: widget.list.name,
        subtitle: subtitle,
        onBack: () => Navigator.of(context).maybePop(),
        onRename: _renameList,
        onDelete: _deleteList,
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
      body: ListDetailBody(
        items: items,
        grouped: grouped,
        categoriesWithItems: categoriesWithItems,
        onRemoveByItemId: (itemId) {
          final realIndex = widget.list.items.indexWhere((e) => e.id == itemId);
          if (realIndex != -1) _removeItemWithUndo(realIndex);
        },
      ),
    );
  }
}
