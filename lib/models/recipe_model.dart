import 'package:flutter/material.dart';

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.servings,
    required this.tags,
    required this.ingredients,
    required this.instructions,
    required this.icon,
    this.notes = '',
  });

  final String id;
  final String title;
  final String duration;
  final String difficulty;
  final int servings;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> instructions;
  final IconData icon;
  final String notes;
}

const sampleRecipes = <RecipeModel>[
  RecipeModel(
    id: 'garlic-butter-pasta',
    title: 'Garlic Butter Pasta',
    duration: '20 min',
    difficulty: 'Easy',
    servings: 2,
    tags: ['Quick', 'Dinner'],
    ingredients: ['Pasta', 'Garlic', 'Butter'],
    instructions: [
      'Boil pasta in salted water until al dente.',
      'Melt butter in a pan over medium heat.',
      'Add minced garlic and sauté for 1 minute.',
      'Toss pasta with garlic butter and serve warm.',
    ],
    icon: Icons.ramen_dining,
  ),
  RecipeModel(
    id: 'veggie-stir-fry',
    title: 'Veggie Stir Fry',
    duration: '25 min',
    difficulty: 'Easy',
    servings: 2,
    tags: ['Quick', 'Healthy', 'Vegetarian', 'Dinner'],
    ingredients: ['Broccoli', 'Carrot', 'Soy sauce'],
    instructions: [
      'Heat a pan with a little oil.',
      'Stir-fry chopped vegetables for 6–8 minutes.',
      'Add soy sauce and cook for 2 more minutes.',
      'Serve hot with rice or noodles.',
    ],
    icon: Icons.wb_sunny_outlined,
  ),
  RecipeModel(
    id: 'lentil-soup',
    title: 'Lentil Soup',
    duration: '35 min',
    difficulty: 'Budget',
    servings: 4,
    tags: ['Cheap', 'Healthy', 'Vegetarian', 'Dinner'],
    ingredients: ['Lentils', 'Onion', 'Tomato'],
    instructions: [
      'Sauté diced onion in a pot until soft.',
      'Add lentils, tomato, and water or stock.',
      'Simmer for about 25 minutes until lentils soften.',
      'Season and serve warm.',
    ],
    icon: Icons.soup_kitchen_outlined,
  ),
  RecipeModel(
    id: 'greek-salad-bowl',
    title: 'Greek Salad Bowl',
    duration: '15 min',
    difficulty: 'Fresh',
    servings: 2,
    tags: ['Quick', 'Healthy', 'Vegetarian'],
    ingredients: ['Cucumber', 'Feta', 'Olive'],
    instructions: [
      'Chop cucumber and other fresh vegetables.',
      'Add olives and crumbled feta to a bowl.',
      'Drizzle olive oil and lemon juice.',
      'Toss gently and serve immediately.',
    ],
    icon: Icons.eco_outlined,
  ),
  RecipeModel(
    id: 'chicken-rice-skillet',
    title: 'Chicken Rice Skillet',
    duration: '30 min',
    difficulty: 'Dinner',
    servings: 3,
    tags: ['Dinner'],
    ingredients: ['Chicken', 'Rice', 'Pepper'],
    instructions: [
      'Cook chicken pieces in a skillet until browned.',
      'Add rice, chopped pepper, and broth.',
      'Cover and cook until rice is tender.',
      'Rest for 5 minutes and serve.',
    ],
    icon: Icons.set_meal_outlined,
  ),
];
