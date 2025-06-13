import '../models/recipe.dart';
import '../models/review.dart';
import '../services/database_helper.dart';

class RecipeService {
  Future<List<Recipe>> getAllRecipes() async {
    return await DatabaseHelper.instance.getRecipes();
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    if (category == 'Semua' || category == 'All') {
      return await DatabaseHelper.instance.getRecipes();
    }
    return await DatabaseHelper.instance.getRecipesByCategory(category);
  }

  Future<List<Recipe>> getPopularRecipes() async {
    final allRecipes = await DatabaseHelper.instance.getRecipes();
    return allRecipes.take(5).toList();
  }

  Future<List<Recipe>> getNewestRecipes() async {
    final allRecipes = await DatabaseHelper.instance.getRecipes();
    return allRecipes.reversed.take(5).toList();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    return await DatabaseHelper.instance.getFavoriteRecipes();
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    if (query.isEmpty) {
      return await DatabaseHelper.instance.getRecipes();
    }
    final allRecipes = await DatabaseHelper.instance.getRecipes();
    return allRecipes.where((recipe) => 
      recipe.title.toLowerCase().contains(query.toLowerCase()) ||
      recipe.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<void> toggleFavorite(String recipeId) async {
    await DatabaseHelper.instance.toggleFavorite(recipeId);
  }
  
  Future<List<Review>> getReviewsForRecipe(String recipeId) async {
    // Placeholder: Implementasikan logika untuk mengambil review dari DatabaseHelper
    // Misalnya: return await DatabaseHelper.instance.getReviewsForRecipe(recipeId);
    // Untuk saat ini, kembalikan list kosong jika metode belum ada
    return [];
  }
}