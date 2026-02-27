import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../theme/app_colors.dart';

class RecipeDetailsPage extends StatefulWidget {
  const RecipeDetailsPage({super.key, required this.recipe});

  final RecipeModel recipe;

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isFavorite = false;
  bool _showCollapsedTitle = false;
  bool _hasPremiumSubscription = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.hasClients ? _scrollController.offset : 0;
    final nextShowCollapsedTitle = offset > 110;

    if (nextShowCollapsedTitle != _showCollapsedTitle) {
      setState(() {
        _showCollapsedTitle = nextShowCollapsedTitle;
      });
    }
  }

  void _onAddIngredientsToList() {
    if (!_hasPremiumSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need a premium plan to use this feature.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Choose a list to add ingredients.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: AppColors.sageTop,
      appBar: AppBar(
        backgroundColor: AppColors.sageTop,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 116,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandGreen,
            padding: const EdgeInsets.only(left: 4, right: 8),
          ),
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          label: const Text(
            'Recipes',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _showCollapsedTitle
              ? Row(
                  key: const ValueKey('collapsed-title'),
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(
                      _isFavorite ? Icons.star : Icons.star_border,
                      size: 18,
                      color: AppColors.brandGreen,
                    ),
                  ],
                )
              : const SizedBox(key: ValueKey('expanded-title'), height: 1),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withOpacity(0.085),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(recipe.icon, color: AppColors.brandGreen),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '⏱ ${recipe.duration}  •  ${recipe.difficulty}  •  ${recipe.servings} servings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recipe.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.brandGreen.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.brandGreen.withOpacity(
                                      0.18,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: AppColors.brandGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last cooked: Never',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandGreen,
                    side: BorderSide(
                      color: AppColors.brandGreen.withOpacity(0.28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
                  label: Text(_isFavorite ? 'Favorited' : 'Favorite'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to meal plan')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandGreen,
                    side: BorderSide(
                      color: AppColors.brandGreen.withOpacity(0.28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Add to Plan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.inputBorder),
          const SizedBox(height: 8),
          Text(
            'Ingredients (${recipe.ingredients.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              children: [
                for (var i = 0; i < recipe.ingredients.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: i == recipe.ingredients.length - 1
                          ? null
                          : const Border(
                              bottom: BorderSide(color: AppColors.inputBorder),
                            ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        recipe.ingredients[i],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onAddIngredientsToList,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.playlist_add),
              label: const Text('Add ingredients to list'),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.inputBorder),
          const SizedBox(height: 8),
          Text(
            'Instructions (${recipe.instructions.length} steps)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              children: [
                for (var i = 0; i < recipe.instructions.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      border: i == recipe.instructions.length - 1
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: AppColors.inputBorder.withOpacity(0.68),
                              ),
                            ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.brandGreen,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recipe.instructions[i],
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (recipe.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.inputBorder),
            const SizedBox(height: 8),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Text(
                recipe.notes,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
