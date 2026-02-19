import 'package:flutter/material.dart';
import 'home_page.dart';
// import 'recipes_page.dart';
// import 'meal_plan_page.dart';
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
    const Placeholder(), // RecipesPage()
    const Placeholder(), // MealPlanPage()
    const Placeholder(), // SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;

          return NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: cs.surface,
              surfaceTintColor: Colors
                  .transparent, // avoids Material 3 surface tint making it look "different"
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
          );
        },
      ),
    );
  }
}
