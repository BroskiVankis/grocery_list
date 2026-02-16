/// Returns an emoji that best matches a grocery item name.
///
/// This is a lightweight, local-only helper.
/// You can extend it over time (or later replace it with a smarter mapper).
String emojiForItem(String name) {
  final n = name.toLowerCase().trim();

  // Fruits
  if (n.contains('apple')) return '🍎';
  if (n.contains('banana')) return '🍌';
  if (n.contains('orange')) return '🍊';
  if (n.contains('lemon')) return '🍋';
  if (n.contains('grape')) return '🍇';
  if (n.contains('strawber')) return '🍓';
  if (n.contains('blueber')) return '🫐';
  if (n.contains('cherry')) return '🍒';
  if (n.contains('pear')) return '🍐';
  if (n.contains('peach')) return '🍑';
  if (n.contains('watermelon')) return '🍉';
  if (n.contains('pineapple')) return '🍍';
  if (n.contains('avocado')) return '🥑';

  // Vegetables
  if (n.contains('tomato')) return '🍅';
  if (n.contains('potato')) return '🥔';
  if (n.contains('carrot')) return '🥕';
  if (n.contains('onion')) return '🧅';
  if (n.contains('garlic')) return '🧄';
  if (n.contains('pepper')) return '🫑';
  if (n.contains('cucumber')) return '🥒';
  if (n.contains('lettuce') || n.contains('salad')) return '🥬';
  if (n.contains('broccoli')) return '🥦';
  if (n.contains('corn')) return '🌽';
  if (n.contains('mushroom')) return '🍄';

  // Bakery / grains
  if (n.contains('bread') || n.contains('bun')) return '🍞';
  if (n.contains('rice')) return '🍚';
  if (n.contains('pasta') || n.contains('spaghetti')) return '🍝';

  // Dairy / protein
  if (n.contains('milk')) return '🥛';
  if (n.contains('cheese')) return '🧀';
  if (n.contains('yogurt')) return '🥣';
  if (n.contains('egg')) return '🥚';
  if (n.contains('chicken')) return '🍗';
  if (n.contains('beef') || n.contains('steak')) return '🥩';
  if (n.contains('fish') || n.contains('salmon') || n.contains('tuna')) {
    return '🐟';
  }

  // Drinks / snacks
  if (n.contains('coffee')) return '☕️';
  if (n.contains('tea')) return '🫖';
  if (n.contains('water')) return '💧';
  if (n.contains('juice')) return '🧃';
  if (n.contains('chocolate')) return '🍫';
  if (n.contains('cookie') || n.contains('biscuit')) return '🍪';

  // Default
  return '🛒';
}
