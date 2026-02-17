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
    final scheme = Theme.of(context).colorScheme;

    final groupedResult = groupItemsByCategory(items);
    final grouped = groupedResult.grouped;
    final categoriesWithItems = groupedResult.categoriesWithItems;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 92,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  scheme.primary.withOpacity(0.22),
                  scheme.surface,
                ),
                Color.alphaBlend(
                  scheme.primary.withOpacity(0.10),
                  scheme.surface,
                ),
                scheme.surface,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: scheme.outlineVariant.withOpacity(0.55),
                      ),
                    ),
                    child: IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: scheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Icon badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: scheme.primary.withOpacity(0.18),
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_basket_outlined,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.list.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface.withOpacity(0.60),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
