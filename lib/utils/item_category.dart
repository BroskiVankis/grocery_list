/// Decides which category an item belongs to based on its name.
/// Simple keyword-based approach for local MVP.
/// You can extend this list over time.
String categoryForItem(String name) {
  final n = name.toLowerCase().trim();

  // Fruits
  if (_hasAny(n, [
    'apple',
    'banana',
    'orange',
    'lemon',
    'lime',
    'grape',
    'strawber', // strawberry / strawberries
    'blueber', // blueberry / blueberries
    'raspber',
    'blackber',
    'cherry',
    'pear',
    'peach',
    'plum',
    'apricot',
    'watermelon',
    'melon',
    'pineapple',
    'mango',
    'kiwi',
    'avocado',
    'coconut',
  ])) {
    return 'Fruits';
  }

  // Vegetables
  if (_hasAny(n, [
    'tomato',
    'potato',
    'carrot',
    'onion',
    'garlic',
    'pepper',
    'cucumber',
    'lettuce',
    'salad',
    'broccoli',
    'cauliflower',
    'spinach',
    'corn',
    'mushroom',
    'zucchini',
    'aubergine',
    'eggplant',
    'cabbage',
    'celery',
    'beet',
    'beetroot',
    'peas',
    'bean',
  ])) {
    return 'Vegetables';
  }

  // Dairy
  if (_hasAny(n, [
    'milk',
    'cheese',
    'yogurt',
    'yoghurt',
    'butter',
    'cream',
    'sour cream',
    'kefir',
    'cottage',
    'mozzarella',
    'feta',
    'eggs', // keep eggs in dairy for your preference
    'egg',
  ])) {
    return 'Dairy';
  }

  // Meat / Protein (you can rename this category later)
  if (_hasAny(n, [
    'chicken',
    'beef',
    'steak',
    'pork',
    'turkey',
    'lamb',
    'bacon',
    'sausage',
    'ham',
    'fish',
    'salmon',
    'tuna',
    'shrimp',
    'prawn',
  ])) {
    return 'Meat';
  }

  // Bakery / Grains
  if (_hasAny(n, [
    'bread',
    'bun',
    'bagel',
    'croissant',
    'flour',
    'rice',
    'pasta',
    'spaghetti',
    'noodle',
    'oats',
    'cereal',
  ])) {
    return 'Bakery';
  }

  // Drinks
  if (_hasAny(n, [
    'water',
    'juice',
    'coffee',
    'tea',
    'cola',
    'soda',
    'sparkling',
    'beer',
    'wine',
  ])) {
    return 'Drinks';
  }

  // Snacks / Sweets
  if (_hasAny(n, [
    'chocolate',
    'cookie',
    'biscuit',
    'chips',
    'crackers',
    'snack',
    'nuts',
    'popcorn',
    'candy',
  ])) {
    return 'Snacks';
  }

  return 'Other';
}

bool _hasAny(String text, List<String> keywords) {
  for (final k in keywords) {
    if (text.contains(k)) return true;
  }
  return false;
}
