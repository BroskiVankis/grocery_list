class UserRecipe {
  final String id;
  final String title;
  final String imageUrl;
  final bool isUserCreated;
  final bool isSaved;

  const UserRecipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.isUserCreated,
    required this.isSaved,
  });
}

class YourRecipesData {
  final List<UserRecipe> createdByYou;
  final List<UserRecipe> savedRecipes;

  const YourRecipesData({
    required this.createdByYou,
    required this.savedRecipes,
  });
}
