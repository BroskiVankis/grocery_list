import '../models/grocery_models.dart';

const defaultCategoryOrder = [
  'Fruits',
  'Vegetables',
  'Dairy',
  'Meat',
  'Bakery',
  'Drinks',
  'Snacks',
  'Other',
];

class GroupedItems {
  GroupedItems({required this.grouped, required this.categoriesWithItems});

  final Map<String, List<GroceryItem>> grouped;
  final List<String> categoriesWithItems;
}

GroupedItems groupItemsByCategory(
  List<GroceryItem> items, {
  List<String> categoryOrder = defaultCategoryOrder,
}) {
  final grouped = <String, List<GroceryItem>>{
    for (final c in categoryOrder) c: <GroceryItem>[],
  };

  for (final item in items) {
    (grouped[item.category] ?? grouped['Other']!).add(item);
  }

  final categoriesWithItems = categoryOrder
      .where((c) => grouped[c]!.isNotEmpty)
      .toList();

  return GroupedItems(
    grouped: grouped,
    categoriesWithItems: categoriesWithItems,
  );
}
