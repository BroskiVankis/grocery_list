import 'package:flutter/material.dart';
import '../models/grocery_models.dart';
import '../theme/app_colors.dart';
import 'list_detail_page.dart';
import '../widgets/grocery_list_card.dart';
import '../widgets/sheets/create_list_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<GroceryListModel> lists = [];
  bool _emptyStateIntroVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _emptyStateIntroVisible = true);
    });
  }

  void _refresh() => setState(() {});

  void _showCreateListSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.40),
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

  Future<void> _openList(GroceryListModel list) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListDetailPage(list: list, onChanged: _refresh),
      ),
    );

    if (result == 'delete') {
      setState(() {
        lists.remove(list);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLists = lists.length;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: AppColors.sageTop,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brandGreen.withOpacity(0.20),
                AppColors.brandGreen.withOpacity(0.16),
                AppColors.brandGreen.withOpacity(0.05),
                AppColors.sageTop,
              ],
              stops: const [0.0, 0.34, 0.72, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.brandGreen.withOpacity(0.20),
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_basket_outlined,
                      color: AppColors.brandGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shared Lists',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalLists == 0
                              ? 'Create lists and share with family in real time.'
                              : '$totalLists list${totalLists == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary.withOpacity(
                                  totalLists == 0 ? 0.9 : 0.78,
                                ),
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
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: lists.isEmpty
            ? const SizedBox(key: ValueKey('no-fab'))
            : Padding(
                key: const ValueKey('fab'),
                padding: EdgeInsets.only(bottom: safeBottom + 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2E000000),
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    mini: true,
                    elevation: 0,
                    highlightElevation: 0,
                    onPressed: _showCreateListSheet,
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.white,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
      ),
      body: lists.isEmpty
          ? Center(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        opacity: _emptyStateIntroVisible ? 1 : 0,
                        child: Icon(
                          Icons.shopping_basket_outlined,
                          size: 56,
                          color: AppColors.brandGreen.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        offset: _emptyStateIntroVisible
                            ? Offset.zero
                            : const Offset(0, 0.08),
                        child: Column(
                          children: [
                            Text(
                              'No lists yet',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start your first shared shopping list.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary.withOpacity(
                                      0.75,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        scale: _emptyStateIntroVisible ? 1 : 0.96,
                        child: OutlinedButton(
                          onPressed: _showCreateListSheet,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brandGreen,
                            backgroundColor: AppColors.brandGreen.withOpacity(
                              0.08,
                            ),
                            elevation: 1,
                            side: BorderSide(
                              color: AppColors.brandGreen.withOpacity(0.55),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Create list'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 108),
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
