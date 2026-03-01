import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'home_page.dart';
import 'meal_plan_page.dart';
import 'recipes_page.dart';
// import 'settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  late final _pages = <Widget>[
    const HomePage(),
    const RecipesPage(),
    const MealPlanPage(),
    const Placeholder(), // SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Builder(
        builder: (context) {
          return NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 74,
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors
                  .transparent, // avoids Material 3 surface tint making it look "different"
              indicatorColor: AppColors.brandGreen.withOpacity(0.20),
              iconTheme: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const IconThemeData(color: AppColors.pressedGreen);
                }
                return const IconThemeData(color: AppColors.textSecondary);
              }),
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(
                    color: AppColors.pressedGreen,
                    fontWeight: FontWeight.w700,
                  );
                }
                return const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                );
              }),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.brandGreen.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.list_alt_outlined),
                    selectedIcon: Icon(Icons.list_alt),
                    label: 'Lists',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.restaurant_menu_outlined),
                    selectedIcon: Icon(Icons.restaurant_menu),
                    label: 'Recipes',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: 'Meal Plan',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
