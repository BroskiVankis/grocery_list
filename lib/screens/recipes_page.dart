import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import 'add_recipe_page.dart';
import 'recipe_details_page.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_floating_action_button.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTags = <String>{};
  final List<RecipeModel> _recipes = List<RecipeModel>.from(sampleRecipes);

  static const _tags = ['Quick', 'Healthy', 'Dinner', 'Cheap', 'Vegetarian'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _openAddRecipe() async {
    final newRecipe = await Navigator.of(context).push<RecipeModel>(
      MaterialPageRoute(builder: (_) => const AddRecipePage()),
    );

    if (newRecipe == null) return;

    setState(() {
      _recipes.insert(0, newRecipe);
    });
  }

  List<RecipeModel> get _filteredRecipes {
    final query = _searchController.text.trim().toLowerCase();

    return _recipes.where((recipe) {
      final matchesTags =
          _selectedTags.isEmpty || _selectedTags.every(recipe.tags.contains);
      if (!matchesTags) return false;

      if (query.isEmpty) return true;
      final titleMatch = recipe.title.toLowerCase().contains(query);
      final ingredientMatch = recipe.ingredients.any(
        (ingredient) => ingredient.toLowerCase().contains(query),
      );
      return titleMatch || ingredientMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = _filteredRecipes;

    return Scaffold(
      backgroundColor: AppColors.sageTop,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AppFloatingActionButton(
        tooltip: 'Add recipe',
        shadowColor: Colors.black.withOpacity(0.10),
        shadowBlur: 24,
        shadowOffset: const Offset(0, 8),
        onPressed: _openAddRecipe,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
          children: [
            Text(
              'Recipes',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              cursorColor: AppColors.brandGreen,
              decoration: InputDecoration(
                hintText: 'Search recipes or ingredients',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.inputBorderSoft,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.brandGreen,
                    width: 1.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tag = _tags[index];
                  final selected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => _toggleTag(tag),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.brandGreen.withOpacity(0.22)
                            : AppColors.brandGreen.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? AppColors.brandGreen.withOpacity(0.35)
                              : AppColors.brandGreen.withOpacity(0.18),
                        ),
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          color: selected
                              ? AppColors.pressedGreen
                              : AppColors.brandGreen,
                          fontWeight: FontWeight.w700,
                        ),
                        child: Text(tag),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ...filteredRecipes.map((recipe) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecipeCard(
                  recipe: recipe,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailsPage(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});

  final RecipeModel recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withOpacity(0.085),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(recipe.icon, color: AppColors.brandGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '⏱ ${recipe.duration}  •  ',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: recipe.difficulty,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withOpacity(0.56),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
