import 'package:grocery_list/models/user_recipe_model.dart';

class YourRecipesRepository {
  Future<YourRecipesData> fetchRecipes() async {
    return const YourRecipesData(
      createdByYou: [
        UserRecipe(
          id: 'created-1',
          title: 'Creamy Mushroom Pasta',
          imageUrl:
              'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800',
          isUserCreated: true,
          isSaved: false,
        ),
        UserRecipe(
          id: 'created-2',
          title: 'Spicy Chickpea Bowl',
          imageUrl:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
          isUserCreated: true,
          isSaved: false,
        ),
      ],
      savedRecipes: [
        UserRecipe(
          id: 'saved-1',
          title: 'Avocado Toast Deluxe',
          imageUrl:
              'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800',
          isUserCreated: false,
          isSaved: true,
        ),
        UserRecipe(
          id: 'saved-2',
          title: 'Lemon Garlic Salmon',
          imageUrl:
              'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800',
          isUserCreated: false,
          isSaved: true,
        ),
        UserRecipe(
          id: 'saved-3',
          title: 'Berry Oat Parfait',
          imageUrl:
              'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800',
          isUserCreated: false,
          isSaved: true,
        ),
      ],
    );
  }

  Future<int> getSavedRecipesCount() async {
    final data = await fetchRecipes();
    return data.savedRecipes.length;
  }
}
