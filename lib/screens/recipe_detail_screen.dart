import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_list/models/recipe_detail_data.dart';
import 'package:grocery_list/theme/app_colors.dart';
import 'package:grocery_list/widgets/recipe_detail/bottom_action_bar.dart';
import 'package:grocery_list/widgets/recipe_detail/ingredients_section.dart';
import 'package:grocery_list/widgets/recipe_detail/instructions_section.dart';
import 'package:grocery_list/widgets/recipe_detail/recipe_info_chip.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isSaved = false;
  final Set<int> _checkedIngredients = <int>{};
  final Map<int, GlobalKey> _stepKeys = <int, GlobalKey>{};
  int _currentStepIndex = 0;

  RecipeDetailData get _recipe => recipeDetailForId(widget.recipeId);

  void _toggleSaved() {
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  void _toggleIngredient(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_checkedIngredients.contains(index)) {
        _checkedIngredients.remove(index);
      } else {
        _checkedIngredients.add(index);
      }
    });
  }

  GlobalKey _stepKey(int index) {
    return _stepKeys.putIfAbsent(index, () => GlobalKey());
  }

  void _selectStep(int index) {
    setState(() {
      _currentStepIndex = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextForStep = _stepKey(index).currentContext;
      if (contextForStep == null) return;

      Scrollable.ensureVisible(
        contextForStep,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              _recipe.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const BackButton(color: AppColors.textPrimary),
            actions: [
              IconButton(
                onPressed: _toggleSaved,
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.inputBg,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 56,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.08),
                          Colors.black.withOpacity(0.42),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recipe.title,
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      RecipeInfoChip(
                        label: _recipe.cookTime,
                        icon: Icons.schedule,
                      ),
                      RecipeInfoChip(
                        label: _recipe.servings,
                        icon: Icons.people_outline,
                      ),
                      RecipeInfoChip(
                        label: _recipe.difficulty,
                        icon: Icons.bar_chart_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  IngredientsSection(
                    ingredients: _recipe.ingredients,
                    checkedIngredients: _checkedIngredients,
                    onToggle: _toggleIngredient,
                  ),
                  const SizedBox(height: 32),
                  InstructionsSection(
                    steps: _recipe.steps,
                    currentStepIndex: _currentStepIndex,
                    onSelectStep: _selectStep,
                    stepKeyBuilder: _stepKey,
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: RecipeBottomActionBar(
        onAddToMealPlan: () {},
        onStartCooking: () {},
      ),
    );
  }
}
