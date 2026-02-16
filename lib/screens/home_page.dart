import 'package:flutter/material.dart';
import '../models/grocery_models.dart';
import 'list_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<GroceryListModel> lists = [];

  void _refresh() => setState(() {});

  void _showCreateListSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final scheme = Theme.of(context).colorScheme;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a new list',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'List name',
                  hintText: 'e.g. Weekly groceries',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: scheme.primary, width: 1.8),
                  ),
                ),
                onSubmitted: (_) => _createList(controller.text),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _createList(controller.text),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Create'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createList(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      lists.add(GroceryListModel(name: trimmed));
    });

    Navigator.of(context).pop();
  }

  void _openList(GroceryListModel list) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListDetailPage(list: list, onChanged: _refresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Lists')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListSheet,
        child: const Icon(Icons.add),
      ),
      body: lists.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 56,
                      color: scheme.primary.withOpacity(0.9),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No lists yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create your first list.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: lists.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final list = lists[index];
                  final count = list.items.length;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _openList(list),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      list.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: scheme.onSurface,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (list.isFavorite)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      size: 22,
                                      color: scheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '$count item${count == 1 ? '' : 's'}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
