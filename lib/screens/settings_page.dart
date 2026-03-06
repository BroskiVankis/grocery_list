import 'package:flutter/material.dart';
import 'package:grocery_list/models/food_preferences_model.dart';
import 'package:grocery_list/repositories/food_preferences_repository.dart';
import 'package:grocery_list/repositories/your_recipes_repository.dart';
import 'package:grocery_list/screens/account_screen.dart';
import 'package:grocery_list/screens/food_preferences_screen.dart';
import 'package:grocery_list/screens/subscription_screen.dart';
import 'package:grocery_list/screens/your_recipes_screen.dart';
import 'package:grocery_list/models/settings_item.dart';
import 'package:grocery_list/theme/app_colors.dart';
import 'package:grocery_list/widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FoodPreferencesRepository _foodPreferencesRepository =
      FoodPreferencesRepository();
  final YourRecipesRepository _yourRecipesRepository = YourRecipesRepository();

  late final List<SettingsItem> _items;
  late final List<List<SettingsItem>> _groups;
  late final List<String> _groupHeaders;
  String _foodPreferencesSummary = 'Not set';
  String _yourRecipesSummary = '0 saved recipes';

  @override
  void initState() {
    super.initState();
    _items = SettingsItem.defaultItems;
    _groups = [_items.sublist(0, 4), _items.sublist(4, 7), _items.sublist(7)];
    _groupHeaders = ['Preferences', 'Support', 'About'];
    _loadFoodPreferencesSummary();
    _loadYourRecipesSummary();
  }

  Future<void> _loadFoodPreferencesSummary() async {
    final preferences = await _foodPreferencesRepository.load();
    final summary = _buildFoodPreferencesSummary(preferences);
    if (!mounted) return;

    setState(() {
      _foodPreferencesSummary = summary;
    });
  }

  String _buildFoodPreferencesSummary(FoodPreferences preferences) {
    final parts = <String>[];

    if (preferences.dietType != null && preferences.dietType!.isNotEmpty) {
      parts.add(preferences.dietType!);
    }
    if (preferences.allergies.isNotEmpty) {
      parts.add('${preferences.allergies.length} allergies');
    }
    if (preferences.dislikes.isNotEmpty) {
      parts.add('${preferences.dislikes.length} dislikes');
    }

    if (parts.isEmpty) {
      return 'Not set';
    }

    return parts.join(' • ');
  }

  Future<void> _loadYourRecipesSummary() async {
    final savedCount = await _yourRecipesRepository.getSavedRecipesCount();
    if (!mounted) return;

    setState(() {
      _yourRecipesSummary = '$savedCount saved recipes';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: Navigator.canPop(context),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          itemCount: _groups.length,
          itemBuilder: (context, groupIndex) {
            final group = _groups[groupIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Text(
                    _groupHeaders[groupIndex].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.1,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (
                        var rowIndex = 0;
                        rowIndex < group.length;
                        rowIndex++
                      ) ...[
                        ColoredBox(
                          color: groupIndex == 0 && rowIndex == 0
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.transparent,
                          child: SettingsTile(
                            icon: group[rowIndex].icon,
                            title: group[rowIndex].title,
                            subtitle:
                                group[rowIndex].title == 'Food Preferences'
                                ? _foodPreferencesSummary
                                : group[rowIndex].title == 'Your Recipes'
                                ? _yourRecipesSummary
                                : null,
                            onTap: () async {
                              if (group[rowIndex].title == 'Food Preferences') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const FoodPreferencesScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                await _loadFoodPreferencesSummary();
                                return;
                              }

                              if (group[rowIndex].title == 'Your Recipes') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const YourRecipesScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                await _loadYourRecipesSummary();
                                return;
                              }

                              if (group[rowIndex].title == 'Account') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const AccountScreen(),
                                  ),
                                );
                                return;
                              }

                              if (group[rowIndex].title == 'Subscription') {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const SubscriptionScreen(),
                                  ),
                                );
                                return;
                              }

                              Navigator.pushNamed(
                                context,
                                group[rowIndex].route,
                              );
                            },
                          ),
                        ),
                        if (rowIndex != group.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.inputBorderSoft,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 24),
        ),
      ),
    );
  }
}
