class GroceryItem {
  GroceryItem({required this.name});

  final String name;
}

class GroceryListModel {
  GroceryListModel({required this.name, this.isFavorite = false});

  final String name;
  bool isFavorite;

  final List<GroceryItem> items = [];
}
