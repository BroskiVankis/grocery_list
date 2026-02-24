class GroceryItem {
  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    this.unit = 'pcs',
    this.quantity = 1,
  });

  final String id;
  final String name;
  final String category;
  final String unit;
  final int? quantity;
}

class GroceryListModel {
  GroceryListModel({required this.name, this.isFavorite = false});

  String name;
  bool isFavorite;

  final List<GroceryItem> items = [];
}
