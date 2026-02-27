import 'package:flutter/material.dart';

import '../models/grocery_models.dart';
import '../theme/app_colors.dart';
import '../utils/group_items.dart';
import '../utils/item_category.dart';
import '../utils/undo_remove.dart';
import '../widgets/common/app_floating_action_button.dart';
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

  String _normalizeItemName(String value) => value.trim().toLowerCase();

  Future<void> _renameList() async {
    final controller = TextEditingController(text: widget.list.name);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Rename list'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            cursorColor: AppColors.brandGreen,
            decoration: InputDecoration(
              hintText: 'List name',
              filled: true,
              fillColor: AppColors.inputBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.inputBorderSoft),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.brandGreen,
                  width: 1.8,
                ),
              ),
            ),
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: AppColors.white,
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
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Delete list?'),
          content: const Text('This will remove the list and all its items.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pressedGreen,
                foregroundColor: AppColors.white,
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
      backgroundColor: AppColors.sageTop,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: ListDetailAppBar(
        title: widget.list.name,
        subtitle: subtitle,
        onBack: () => Navigator.of(context).maybePop(),
        onRename: _renameList,
        onDelete: _deleteList,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: AppFloatingActionButton(
          shadowColor: Colors.black.withOpacity(0.18),
          shadowBlur: 12,
          shadowOffset: const Offset(0, 6),
          onPressed: () => showAddItemSheet(
            context: context,
            onAdd: (text, quantity, unit) {
              setState(() {
                final normalizedName = _normalizeItemName(text);
                final existingIndex = widget.list.items.indexWhere(
                  (item) =>
                      _normalizeItemName(item.name) == normalizedName &&
                      item.unit == unit,
                );

                if (existingIndex != -1) {
                  final existingItem = widget.list.items[existingIndex];
                  widget.list.items[existingIndex] = GroceryItem(
                    id: existingItem.id,
                    name: existingItem.name,
                    category: existingItem.category,
                    unit: existingItem.unit,
                    quantity: (existingItem.quantity ?? 1) + quantity,
                  );
                } else {
                  widget.list.items.add(
                    GroceryItem(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: text,
                      category: categoryForItem(text),
                      unit: unit,
                      quantity: quantity,
                    ),
                  );
                }
              });
              widget.onChanged();
            },
          ),
        ),
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
