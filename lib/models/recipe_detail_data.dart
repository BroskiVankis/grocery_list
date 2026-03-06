class RecipeDetailData {
  final String title;
  final String imageUrl;
  final String cookTime;
  final String servings;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;

  const RecipeDetailData({
    required this.title,
    required this.imageUrl,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });
}

const Map<String, RecipeDetailData> mockRecipeDetailsById = {
  'created-1': RecipeDetailData(
    title: 'Creamy Mushroom Pasta',
    imageUrl:
        'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=1200',
    cookTime: '25 min',
    servings: '2 servings',
    difficulty: 'Easy',
    ingredients: [
      '200g pasta',
      '1 tbsp olive oil',
      '2 cloves garlic, minced',
      '200g mushrooms, sliced',
      '1/2 cup cream',
      'Salt and pepper',
    ],
    steps: [
      'Cook pasta in salted water until al dente, then drain.',
      'Heat olive oil and sauté garlic for 30 seconds.',
      'Add mushrooms and cook until soft and golden.',
      'Pour in cream, season, and simmer for 2 minutes.',
      'Toss pasta with sauce and serve warm.',
    ],
  ),
  'created-2': RecipeDetailData(
    title: 'Spicy Chickpea Bowl',
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
    cookTime: '20 min',
    servings: '2 servings',
    difficulty: 'Easy',
    ingredients: [
      '1 can chickpeas',
      '1 tsp paprika',
      '1 tsp chili flakes',
      '2 cups mixed greens',
      '1/2 avocado',
      'Lemon juice',
    ],
    steps: [
      'Rinse chickpeas and pat dry.',
      'Season with paprika and chili, then pan-roast until crisp.',
      'Arrange greens and sliced avocado in a bowl.',
      'Top with warm chickpeas and finish with lemon juice.',
    ],
  ),
  'saved-1': RecipeDetailData(
    title: 'Avocado Toast Deluxe',
    imageUrl:
        'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=1200',
    cookTime: '10 min',
    servings: '1 serving',
    difficulty: 'Easy',
    ingredients: [
      '2 slices sourdough bread',
      '1 ripe avocado',
      '1 tsp lemon juice',
      'Chili flakes',
      'Salt',
    ],
    steps: [
      'Toast bread until golden.',
      'Mash avocado with lemon juice and salt.',
      'Spread avocado on toast and top with chili flakes.',
    ],
  ),
};

const RecipeDetailData fallbackRecipeDetail = RecipeDetailData(
  title: 'Recipe Details',
  imageUrl:
      'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=1200',
  cookTime: '25 min',
  servings: '2 servings',
  difficulty: 'Medium',
  ingredients: [
    '1 main ingredient',
    '2 supporting ingredients',
    'Seasoning to taste',
  ],
  steps: [
    'Prepare all ingredients.',
    'Cook according to your preferred method.',
    'Plate and serve warm.',
  ],
);

RecipeDetailData recipeDetailForId(String recipeId) {
  return mockRecipeDetailsById[recipeId] ?? fallbackRecipeDetail;
}
