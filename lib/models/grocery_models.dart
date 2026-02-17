class GroceryItem {
  GroceryItem({required this.id, required this.name, required this.category});

  final String id;
  final String name;
  final String category;
}

class GroceryListModel {
  GroceryListModel({required this.name, this.isFavorite = false});

  final String name;
  bool isFavorite;

  final List<GroceryItem> items = [];
}
