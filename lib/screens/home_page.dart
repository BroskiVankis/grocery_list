import 'package:flutter/material.dart';
import '../models/grocery_models.dart';
import 'list_detail_page.dart';
import '../widgets/grocery_list_card.dart';
import '../widgets/create_list_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<GroceryListModel> lists = [];

  void _refresh() => setState(() {});

  void _showCreateListSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return CreateListSheet(onCreate: (name) => _createList(name));
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
    final totalLists = lists.length;
    final favoriteCount = lists.where((l) => l.isFavorite).length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 92,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withOpacity(0.32),
                scheme.primary.withOpacity(0.10),
                scheme.surface,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Lists',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          totalLists == 0
                              ? 'Create your first shopping list'
                              : '$totalLists list${totalLists == 1 ? '' : 's'} • $favoriteCount saved',
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
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: lists.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final list = lists[index];
                final count = list.items.length;

                return GroceryListCard(
                  list: list,
                  itemCount: count,
                  onTap: () => _openList(list),
                );
              },
            ),
    );
  }
}
