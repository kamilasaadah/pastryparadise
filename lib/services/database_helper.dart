import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../models/category.dart' as my_models;
import '../models/review.dart';
import '../models/tip.dart';
import '../models/ingredient.dart';
import '../models/step.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();
  static const String _pocketBaseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_pocketBaseUrl/api/collections/users/records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'passwordConfirm': password.trim(),
          'emailVisibility': true,
          'verified': false,
        }),
      );

      debugPrint('Register user status: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_pocketBaseUrl/api/collections/users/auth-with-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identity': email.trim(),
          'password': password.trim(),
        }),
      );

      debugPrint('Login status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['record'];
        final authToken = responseData['token'];

        await saveUserData({
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'token': authToken,
          'profile_image': userData['avatar'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
        });

        return {
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'profile_image': userData['avatar'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('User logged out');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');
    final profileImage = prefs.getString('profile_image');

    if (userId != null && userName != null && userEmail != null) {
      return {
        'id': userId,
        'name': userName,
        'email': userEmail,
        'profile_image': profileImage ?? 'https://randomuser.me/api/portraits/men/32.jpg',
      };
    }

    final authToken = await _getAuthToken();
    if (authToken != null && userId != null) {
      try {
        final response = await http.get(
          Uri.parse('$_pocketBaseUrl/api/collections/users/records/$userId'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        );

        debugPrint('Fetch user status: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          await saveUserData({
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'token': authToken,
            'profile_image': userData['avatar'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
          });
          return {
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'profile_image': userData['avatar'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
          };
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
    return null;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['id']);
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setString('auth_token', userData['token'] ?? '');
    await prefs.setString('profile_image', userData['profile_image'] ?? 'https://randomuser.me/api/portraits/men/32.jpg');
    debugPrint('User data saved: ${userData['id']}');
  }

  // NEW: Get all categories from PocketBase
  Future<List<my_models.Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/category/records'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Get categories status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => my_models.Category.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // Helper method to set favorite status for multiple recipes
  Future<List<Recipe>> _setFavoriteStatus(List<Recipe> recipes) async {
    final user = await getCurrentUser();
    if (user == null) return recipes;

    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      // Get all favorites for current user
      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/favorites/records?filter=user_id="${user['id']}"'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favoriteItems = data['items'] ?? [];
        final Set<String> favoriteRecipeIds = favoriteItems
            .map((item) => item['recipe_id'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toSet();

        // Update recipes with favorite status
        return recipes.map((recipe) {
          final isFavorite = favoriteRecipeIds.contains(recipe.id);
          return recipe.copyWith(isFavorite: isFavorite);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error setting favorite status: $e');
    }

    return recipes;
  }

  Future<List<Recipe>> getRecipes() async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/recipes/records?expand=ingredients,steps,id_category'),
        headers: headers,
      );

      debugPrint('=== GET RECIPES DEBUG ===');
      debugPrint('Get recipes status: ${response.statusCode}');
      debugPrint('Get recipes response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        // Debug setiap item untuk melihat field difficulty
        debugPrint('=== INDIVIDUAL RECIPE DEBUG ===');
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          debugPrint('Recipe $i: ${item['title']} - Difficulty: "${item['difficulty']}" (${item['difficulty'].runtimeType})');
        }
        
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        // Debug hasil parsing
        debugPrint('=== PARSED RECIPES DEBUG ===');
        for (int i = 0; i < recipes.length; i++) {
          debugPrint('Parsed Recipe $i: ${recipes[i].title} - Difficulty: "${recipes[i].difficulty}"');
        }
        
        // Set favorite status for all recipes
        return await _setFavoriteStatus(recipes);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> getRecipesByCategory(String categoryId) async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      if (categoryId == 'Semua') {
        return await getRecipes();
      }

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/recipes/records?filter=id_category="$categoryId"&expand=ingredients,steps,id_category'),
        headers: headers,
      );

      debugPrint('Get recipes by category status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        // Set favorite status for all recipes
        return await _setFavoriteStatus(recipes);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recipes by category: $e');
      return [];
    }
  }

  Future<List<Recipe>> getNewestRecipes({int limit = 4}) async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/recipes/records?sort=-created&perPage=$limit&expand=ingredients,steps,id_category'),
        headers: headers,
      );

      debugPrint('=== GET NEWEST RECIPES DEBUG ===');
      debugPrint('Get newest recipes status: ${response.statusCode}');
      debugPrint('Get newest recipes response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        // Debug setiap item untuk melihat field difficulty
        debugPrint('=== NEWEST RECIPES INDIVIDUAL DEBUG ===');
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          debugPrint('Newest Recipe $i: ${item['title']} - Difficulty: "${item['difficulty']}" (${item['difficulty'].runtimeType})');
        }
        
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        // Debug hasil parsing
        debugPrint('=== NEWEST PARSED RECIPES DEBUG ===');
        for (int i = 0; i < recipes.length; i++) {
          debugPrint('Newest Parsed Recipe $i: ${recipes[i].title} - Difficulty: "${recipes[i].difficulty}"');
        }
        
        // Set favorite status for all recipes
        return await _setFavoriteStatus(recipes);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching newest recipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final user = await getCurrentUser();
    if (user == null) {
      debugPrint('No user logged in for fetching favorite recipes');
      return [];
    }

    try {
      final authToken = await _getAuthToken();
      debugPrint('Auth token used: $authToken');
      debugPrint('User ID used: ${user['id']}');
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      // First get all favorite records for the user
      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/favorites/records?filter=user_id="${user['id']}"'),
        headers: headers,
      );

      debugPrint('Get favorite records status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favoriteItems = data['items'] ?? [];
        debugPrint('Favorite items raw: $favoriteItems');

        if (favoriteItems.isEmpty) {
          debugPrint('No favorite items found');
          return [];
        }

        // Extract recipe IDs from favorites
        final List<String> recipeIds = favoriteItems
            .map((item) => item['recipe_id'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toList();

        debugPrint('Recipe IDs from favorites: $recipeIds');

        if (recipeIds.isEmpty) {
          debugPrint('No valid recipe IDs found in favorites');
          return [];
        }

        // Now fetch the actual recipes
        final List<Recipe> favoriteRecipes = [];
        for (String recipeId in recipeIds) {
          try {
            final recipeResponse = await http.get(
              Uri.parse('$_pocketBaseUrl/api/collections/recipes/records/$recipeId?expand=ingredients,steps,id_category'),
              headers: headers,
            );

            debugPrint('Get recipe $recipeId status: ${recipeResponse.statusCode}');
            if (recipeResponse.statusCode == 200) {
              final recipeData = jsonDecode(recipeResponse.body);
              final recipe = Recipe.fromJson(recipeData);
              favoriteRecipes.add(recipe.copyWith(isFavorite: true));
            }
          } catch (e) {
            debugPrint('Error fetching recipe $recipeId: $e');
          }
        }

        debugPrint('Parsed favorite recipes count: ${favoriteRecipes.length}');
        return favoriteRecipes;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching favorite recipes: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String recipeId) async {
    final user = await getCurrentUser();
    if (user == null) {
      debugPrint('No user logged in for toggling favorite');
      return false;
    }

    try {
      final authToken = await _getAuthToken();
      debugPrint('Auth token used for toggle: $authToken');
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      // Check if favorite already exists
      final checkResponse = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/favorites/records?filter=recipe_id="$recipeId"&&user_id="${user['id']}"'),
        headers: headers,
      );

      debugPrint('Check favorite status: ${checkResponse.statusCode} - ${checkResponse.body}');
      if (checkResponse.statusCode == 200) {
        final data = jsonDecode(checkResponse.body);
        final List<dynamic> items = data['items'] ?? [];
        debugPrint('Check favorite details: $data');

        if (items.isNotEmpty) {
          // Remove from favorites
          final favoriteId = items[0]['id'];
          final deleteResponse = await http.delete(
            Uri.parse('$_pocketBaseUrl/api/collections/favorites/records/$favoriteId'),
            headers: headers,
          );
          debugPrint('Delete favorite status: ${deleteResponse.statusCode} - ${deleteResponse.body}');
          return deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204;
        } else {
          // Add to favorites
          final addResponse = await http.post(
            Uri.parse('$_pocketBaseUrl/api/collections/favorites/records'),
            headers: headers,
            body: jsonEncode({
              'recipe_id': recipeId,
              'user_id': user['id'],
            }),
          );
          debugPrint('Add favorite status: ${addResponse.statusCode} - ${addResponse.body}');
          if (addResponse.statusCode == 200 || addResponse.statusCode == 201) {
            return true;
          } else {
            debugPrint('Failed to add favorite details: ${addResponse.body}');
            return false;
          }
        }
      } else {
        debugPrint('Check favorite failed with status ${checkResponse.statusCode}: ${checkResponse.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/recipes/records?filter=title~"$query"||description~"$query"&expand=ingredients,steps,id_category'),
        headers: headers,
      );

      debugPrint('Search recipes status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        // Set favorite status for all recipes
        return await _setFavoriteStatus(recipes);
      }
      return [];
    } catch (e) {
      debugPrint('Error searching recipes: $e');
      return [];
    }
  }

  Future<List<Tip>> getTips() async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/tips/records'),
        headers: headers,
      );

      debugPrint('Get tips status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => Tip.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching tips: $e');
    }

    return [
      Tip(
        id: 1,
        title: 'Tips Membuat Adonan Puff Pastry yang Sempurna',
        description: 'Pelajari teknik melipat dan mendinginkan adonan untuk hasil yang berlapis-lapis.',
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=1000',
      ),
      Tip(
        id: 2,
        title: 'Teknik Dekorasi Kue Tart untuk Pemula',
        description: 'Cara mudah menghias kue tart dengan hasil yang profesional.',
        imageUrl: 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?q=80&w=1000',
      ),
      Tip(
        id: 3,
        title: 'Menyimpan Pastry agar Tetap Segar',
        description: 'Tips menyimpan pastry agar tetap renyah dan lezat.',
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=1000',
      ),
      Tip(
        id: 4,
        title: 'Memilih Bahan Berkualitas untuk Pastry',
        description: 'Pilih tepung dan mentega terbaik untuk hasil pastry yang luar biasa.',
        imageUrl: 'https://images.unsplash.com/photo-1626803775151-61d756612f97?q=80&w=1000',
      ),
    ];
  }

  Future<List<Review>> getReviewsForRecipe(String recipeId) async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/reviews/records?filter=recipe_id="$recipeId"&expand=user_id'),
        headers: headers,
      );

      debugPrint('Get reviews for recipe ID: $recipeId, Status: ${response.statusCode} - Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        final reviews = items.map((item) => Review.fromJson(item)).toList();
        debugPrint('Fetched reviews count: ${reviews.length} - Reviews: $reviews');
        return reviews;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews for recipe: $e');
      return [];
    }
  }

  Future<bool> createReview(String recipeId, double rating, String comment) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        debugPrint('No auth token available');
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final user = await getCurrentUser();
      if (user == null) {
        debugPrint('No user logged in');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_pocketBaseUrl/api/collections/reviews/records'),
        headers: headers,
        body: jsonEncode({
          'recipe_id': recipeId,
          'user_id': user['id'],
          'rating': rating,
          'comment': comment,
          'created': DateTime.now().toIso8601String(),
        }),
      );

      debugPrint('Create review status: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating review: $e');
      return false;
    }
  }

  Future<bool> updateReview(String reviewId, double rating, String comment) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        debugPrint('No auth token available');
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.patch(
        Uri.parse('$_pocketBaseUrl/api/collections/reviews/records/$reviewId'),
        headers: headers,
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
          'updated': DateTime.now().toIso8601String(),
        }),
      );

      debugPrint('Update review status: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        debugPrint('No auth token available');
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.delete(
        Uri.parse('$_pocketBaseUrl/api/collections/reviews/records/$reviewId'),
        headers: headers,
      );

      debugPrint('Delete review status: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  Future<List<Ingredient>> getIngredientsForRecipe(String recipeId) async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/ingredients/records?filter=recipe_id="$recipeId"'),
        headers: headers,
      );

      debugPrint('Get ingredients status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => Ingredient.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching ingredients: $e');
      return [];
    }
  }

  Future<List<Step>> getStepsForRecipe(String recipeId) async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/steps/records?filter=recipe_id="$recipeId"'),
        headers: headers,
      );

      debugPrint('Get steps status: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => Step.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching steps: $e');
      return [];
    }
  }

  Future<String> getUserName(String userId) async {
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/users/records/$userId'),
        headers: headers,
      );

      debugPrint('Get user name for userId: $userId - Status: ${response.statusCode} - Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name'] ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      debugPrint('Error fetching user name for userId $userId: $e');
      return 'Unknown User';
    }
  }

  String dummyVariable = ''; // Variabel dummy untuk memastikan sintaks valid
}
