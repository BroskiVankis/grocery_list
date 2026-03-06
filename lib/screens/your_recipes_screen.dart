import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/models/user_recipe_model.dart';
import 'package:grocery_list/repositories/your_recipes_repository.dart';
import 'package:grocery_list/screens/recipe_detail_screen.dart';
import 'package:grocery_list/theme/app_colors.dart';

class YourRecipesScreen extends StatefulWidget {
  const YourRecipesScreen({super.key});

  @override
  State<YourRecipesScreen> createState() => _YourRecipesScreenState();
}

class _YourRecipesScreenState extends State<YourRecipesScreen> {
  final YourRecipesRepository _repository = YourRecipesRepository();

  static const double _cardRadius = 14;

  bool _isLoading = true;
  List<UserRecipe> _createdByYou = const [];
  List<UserRecipe> _savedRecipes = const [];
  final Set<String> _animatingUnsavedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _repository.fetchRecipes();
    if (!mounted) return;

    setState(() {
      _createdByYou = data.createdByYou;
      _savedRecipes = data.savedRecipes;
      _isLoading = false;
    });
  }

  void _openRecipeDetail(String recipeId) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => RecipeDetailScreen(recipeId: recipeId),
      ),
    );
  }

  Future<void> _openCreatedRecipeActions(UserRecipe recipe) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.of(context).pop('edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'delete') {
      setState(() {
        _createdByYou = _createdByYou
            .where((item) => item.id != recipe.id)
            .toList();
      });
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${recipe.title} (mock)')));
  }

  Future<void> _toggleSavedRecipe(UserRecipe recipe) async {
    if (_animatingUnsavedIds.contains(recipe.id)) {
      return;
    }

    setState(() {
      _animatingUnsavedIds.add(recipe.id);
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    setState(() {
      _animatingUnsavedIds.remove(recipe.id);
      _savedRecipes = _savedRecipes
          .where((item) => item.id != recipe.id)
          .toList();
    });
  }

  Future<bool?> _handleCreatedDismiss(UserRecipe recipe) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () => Navigator.of(context).pop('edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return false;
    }

    if (action == 'delete') {
      setState(() {
        _createdByYou = _createdByYou
            .where((item) => item.id != recipe.id)
            .toList();
      });
      return true;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${recipe.title} (mock)')));
    return false;
  }

  Widget _buildCreatedCard(UserRecipe recipe) {
    return Dismissible(
      key: ValueKey('created-${recipe.id}'),
      direction: DismissDirection.endToStart,
      background: const _SwipeBackground(
        icon: Icons.edit_outlined,
        label: 'Edit',
      ),
      secondaryBackground: const _SwipeBackground(
        icon: Icons.delete_outline,
        label: 'Delete',
        isDestructive: true,
      ),
      confirmDismiss: (_) => _handleCreatedDismiss(recipe),
      child: _RecipeCard(
        recipe: recipe,
        borderRadius: _cardRadius,
        trailing: _TrailingActionButton(
          icon: const Icon(Icons.more_vert),
          onTap: () => _openCreatedRecipeActions(recipe),
        ),
        onTap: () => _openRecipeDetail(recipe.id),
      ),
    );
  }

  Widget _buildSavedCard(UserRecipe recipe) {
    return Dismissible(
      key: ValueKey('saved-${recipe.id}'),
      direction: DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: const _SwipeBackground(
        icon: Icons.bookmark_remove_outlined,
        label: 'Unsave',
      ),
      confirmDismiss: (_) async {
        await _toggleSavedRecipe(recipe);
        return true;
      },
      child: _RecipeCard(
        recipe: recipe,
        borderRadius: _cardRadius,
        trailing: _TrailingActionButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              _animatingUnsavedIds.contains(recipe.id)
                  ? Icons.bookmark_border
                  : Icons.bookmark,
              key: ValueKey<bool>(_animatingUnsavedIds.contains(recipe.id)),
              color: AppColors.primary,
            ),
          ),
          onTap: () => _toggleSavedRecipe(recipe),
        ),
        onTap: () => _openRecipeDetail(recipe.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Your Recipes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'Created by You (${_createdByYou.length})',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_createdByYou.isEmpty)
                  _SmallEmptyMessage(message: 'No recipes created yet.')
                else
                  ..._createdByYou.map(_buildCreatedCard),
                const SizedBox(height: 32),
                Text(
                  'Saved Recipes (${_savedRecipes.length})',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_savedRecipes.isEmpty)
                  _SmallEmptyMessage(message: 'No saved recipes yet.')
                else
                  ..._savedRecipes.map(_buildSavedCard),
              ],
            ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.trailing,
    required this.onTap,
    required this.borderRadius,
  });

  final UserRecipe recipe;
  final Widget trailing;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.inputBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.primary.withOpacity(0.04),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: recipe.imageUrl.isEmpty
                  ? Container(
                      width: 56,
                      height: 56,
                      color: AppColors.inputBg,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Image.network(
                      recipe.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: AppColors.inputBg,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
            title: Text(
              recipe.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}

class _TrailingActionButton extends StatelessWidget {
  const _TrailingActionButton({required this.icon, required this.onTap});

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(child: icon),
        ),
      ),
    );
  }
}

class _SmallEmptyMessage extends StatelessWidget {
  const _SmallEmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDestructive
        ? Colors.red.withOpacity(0.08)
        : AppColors.primary.withOpacity(0.12);
    final fgColor = isDestructive ? Colors.red : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: fgColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
