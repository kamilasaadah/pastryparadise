import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

  // Method untuk menghitung rating rata-rata
  Future<Map<String, Map<String, dynamic>>> _getRecipeRatings(List<String> recipeIds) async {
    final Map<String, Map<String, dynamic>> ratings = {};
    
    if (recipeIds.isEmpty) return ratings;
    
    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final recipeIdsFilter = recipeIds.map((id) => 'recipe_id="$id"').join('||');
      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/reviews/records?filter=($recipeIdsFilter)'),
        headers: headers,
      );

      if (kDebugMode) {
        print('=== GET RECIPE RATINGS DEBUG ===');
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> reviews = data['items'] ?? [];
        
        final Map<String, List<double>> recipeReviews = {};
        
        for (final review in reviews) {
          final recipeId = review['recipe_id'] as String?;
          final rating = (review['rating'] as num?)?.toDouble();
          
          if (recipeId != null && rating != null) {
            recipeReviews.putIfAbsent(recipeId, () => []).add(rating);
          }
        }
        
        for (final entry in recipeReviews.entries) {
          final recipeId = entry.key;
          final ratingList = entry.value;
          final averageRating = ratingList.reduce((a, b) => a + b) / ratingList.length;
          
          ratings[recipeId] = {
            'averageRating': averageRating,
            'reviewCount': ratingList.length,
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating recipe ratings: $e');
      }
    }
    
    return ratings;
  }

  Future<List<Recipe>> _addRatingsToRecipes(List<Recipe> recipes) async {
    if (recipes.isEmpty) return recipes;
    
    final recipeIds = recipes.map((r) => r.id).toList();
    final ratings = await _getRecipeRatings(recipeIds);
    
    return recipes.map((recipe) {
      final ratingData = ratings[recipe.id];
      if (ratingData != null) {
        return recipe.copyWith(
          averageRating: ratingData['averageRating'] ?? 0.0,
          reviewCount: ratingData['reviewCount'] ?? 0,
        );
      }
      return recipe;
    }).toList();
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

        String? avatarUrl;
        if (userData['avatar'] != null && userData['avatar'].isNotEmpty) {
          avatarUrl = '$_pocketBaseUrl/api/files/users/${userData['id']}/${userData['avatar']}';
        }

        await saveUserData({
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'token': authToken,
          'profile_image': avatarUrl ?? 'https://randomuser.me/api/portraits/men/32.jpg',
        });

        return {
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'profile_image': avatarUrl ?? 'https://randomuser.me/api/portraits/men/32.jpg',
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

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          
          String? avatarUrl;
          if (userData['avatar'] != null && userData['avatar'].isNotEmpty) {
            avatarUrl = '$_pocketBaseUrl/api/files/users/${userData['id']}/${userData['avatar']}';
          }
          
          await saveUserData({
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'token': authToken,
            'profile_image': avatarUrl ?? 'https://randomuser.me/api/portraits/men/32.jpg',
          });
          return {
            'id': userData['id'],
            'name': userData['name'],
            'email': userData['email'],
            'profile_image': avatarUrl ?? 'https://randomuser.me/api/portraits/men/32.jpg',
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
  }

  Future<List<my_models.Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/category/records'),
        headers: {'Content-Type': 'application/json'},
      );

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

  Future<List<Recipe>> _setFavoriteStatus(List<Recipe> recipes) async {
    final user = await getCurrentUser();
    if (user == null) return recipes;

    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final favoriteUrl = '$_pocketBaseUrl/api/collections/favorites/records?filter=user_id="${user['id']}"';
      
      final response = await http.get(
        Uri.parse(favoriteUrl),
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

      if (kDebugMode) {
        print('=== GET RECIPES DEBUG ===');
        print('Status: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        final recipesWithFavorites = await _setFavoriteStatus(recipes);
        final recipesWithRatings = await _addRatingsToRecipes(recipesWithFavorites);
        
        return recipesWithRatings;
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        final recipesWithFavorites = await _setFavoriteStatus(recipes);
        return await _addRatingsToRecipes(recipesWithFavorites);
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
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        final recipesWithFavorites = await _setFavoriteStatus(recipes);
        return await _addRatingsToRecipes(recipesWithFavorites);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching newest recipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final user = await getCurrentUser();
    if (user == null) return [];

    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final favoriteUrl = '$_pocketBaseUrl/api/collections/favorites/records?filter=user_id="${user['id']}"';
      
      final response = await http.get(
        Uri.parse(favoriteUrl),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favoriteItems = data['items'] ?? [];

        if (favoriteItems.isEmpty) return [];

        final List<String> recipeIds = favoriteItems
            .map((item) => item['recipe_id'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toList();

        if (recipeIds.isEmpty) return [];

        final recipeIdsFilter = recipeIds.map((id) => 'id="$id"').join('||');
        final recipesUrl = '$_pocketBaseUrl/api/collections/recipes/records?filter=($recipeIdsFilter)&expand=ingredients,steps,id_category';
        
        final recipesResponse = await http.get(
          Uri.parse(recipesUrl),
          headers: headers,
        );

        if (recipesResponse.statusCode == 200) {
          final recipesData = jsonDecode(recipesResponse.body);
          final List<dynamic> recipeItems = recipesData['items'] ?? [];
          
          final List<Recipe> favoriteRecipes = recipeItems.map((item) {
            final recipe = Recipe.fromJson(item);
            return recipe.copyWith(isFavorite: true);
          }).toList();
          
          return await _addRatingsToRecipes(favoriteRecipes);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching favorite recipes: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String recipeId) async {
    final user = await getCurrentUser();
    if (user == null) return false;

    try {
      final authToken = await _getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final checkUrl = '$_pocketBaseUrl/api/collections/favorites/records?filter=recipe_id="$recipeId"&&user_id="${user['id']}"';
      
      final checkResponse = await http.get(
        Uri.parse(checkUrl),
        headers: headers,
      );
      
      if (checkResponse.statusCode == 200) {
        final data = jsonDecode(checkResponse.body);
        final List<dynamic> items = data['items'] ?? [];

        if (items.isNotEmpty) {
          final favoriteId = items[0]['id'];
          
          final deleteResponse = await http.delete(
            Uri.parse('$_pocketBaseUrl/api/collections/favorites/records/$favoriteId'),
            headers: headers,
          );
          return deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204;
        } else {
          final addResponse = await http.post(
            Uri.parse('$_pocketBaseUrl/api/collections/favorites/records'),
            headers: headers,
            body: jsonEncode({
              'recipe_id': recipeId,
              'user_id': user['id'],
            }),
          );
          
          return addResponse.statusCode == 200 || addResponse.statusCode == 201;
        }
      }
      return false;
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        final recipes = items.map((item) => Recipe.fromJson(item)).toList();
        
        final recipesWithFavorites = await _setFavoriteStatus(recipes);
        return await _addRatingsToRecipes(recipesWithFavorites);
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        return items.map((item) => Review.fromJson(item)).toList();
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
      if (authToken == null) return false;

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final user = await getCurrentUser();
      if (user == null) return false;

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

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating review: $e');
      return false;
    }
  }

  Future<bool> updateReview(String reviewId, double rating, String comment) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return false;

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

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) return false;

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.delete(
        Uri.parse('$_pocketBaseUrl/api/collections/reviews/records/$reviewId'),
        headers: headers,
      );

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
      final userInfo = await getUserInfo(userId);
      return userInfo['name'] ?? 'Unknown User';
    } catch (e) {
      debugPrint('Error fetching user name for userId $userId: $e');
      return 'Unknown User';
    }
  }

  Future<Map<String, String>> getUserNames(List<String> userIds) async {
    final Map<String, String> userNames = {};
    
    try {
      final userInfos = await getUserInfos(userIds);
      for (final entry in userInfos.entries) {
        userNames[entry.key] = entry.value['name'] ?? 'Unknown User';
      }
      return userNames;
    } catch (e) {
      debugPrint('Error fetching multiple user names: $e');
      for (final userId in userIds) {
        userNames[userId] = 'Unknown User';
      }
      return userNames;
    }
  }

  Future<Map<String, String?>> getUserInfo(String userId) async {
    try {
      var response = await http.get(
        Uri.parse('$_pocketBaseUrl/api/collections/users/records/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        final authToken = await _getAuthToken();
        if (authToken != null) {
          response = await http.get(
            Uri.parse('$_pocketBaseUrl/api/collections/users/records/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          );
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userName = data['name'] ?? 'Unknown User';
        final avatar = data['avatar'] as String?;
        
        String? avatarUrl;
        if (avatar != null && avatar.isNotEmpty) {
          avatarUrl = '$_pocketBaseUrl/api/files/users/$userId/$avatar';
        }
        
        return {
          'name': userName,
          'avatar': avatarUrl,
        };
      } else {
        return {
          'name': 'Unknown User',
          'avatar': null,
        };
      }
    } catch (e) {
      debugPrint('Error fetching user info for userId $userId: $e');
      return {
        'name': 'Unknown User',
        'avatar': null,
      };
    }
  }

  Future<Map<String, Map<String, String?>>> getUserInfos(List<String> userIds) async {
    final Map<String, Map<String, String?>> userInfos = {};
    
    if (userIds.isEmpty) return userInfos;
    
    try {
      final userIdsFilter = userIds.map((id) => 'id="$id"').join('||');
      final url = '$_pocketBaseUrl/api/collections/users/records?filter=($userIdsFilter)';
      
      var response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final authToken = await _getAuthToken();
        if (authToken != null) {
          response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          );
        }
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        for (final item in items) {
          final userId = item['id'] as String?;
          final userName = item['name'] as String?;
          final avatar = item['avatar'] as String?;
          
          if (userId != null) {
            String? avatarUrl;
            if (avatar != null && avatar.isNotEmpty) {
              avatarUrl = '$_pocketBaseUrl/api/files/users/$userId/$avatar';
            }
            
            userInfos[userId] = {
              'name': userName ?? 'Unknown User',
              'avatar': avatarUrl,
            };
          }
        }
      }
      
      for (final userId in userIds) {
        if (!userInfos.containsKey(userId)) {
          userInfos[userId] = {
            'name': 'Unknown User',
            'avatar': null,
          };
        }
      }
      
      return userInfos;
    } catch (e) {
      debugPrint('Error fetching multiple user infos: $e');
      for (final userId in userIds) {
        userInfos[userId] = {
          'name': 'Unknown User',
          'avatar': null,
        };
      }
      return userInfos;
    }
  }

  String dummyVariable = '';
}
