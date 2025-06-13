import 'dart:developer' as developer;
import 'ingredient.dart';
import 'step.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String image;
  final int prepTime;
  final double cookTime;
  final double servings;
  final String difficulty;
  final String? userId;
  final String? categoryId;
  final List<Ingredient> ingredients;
  final List<Step> steps;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    this.userId,
    this.categoryId,
    this.ingredients = const [],
    this.steps = const [],
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    const String pocketBaseUrl = String.fromEnvironment(
      'POCKETBASE_URL',
      defaultValue: 'http://localhost:8090',
    );
    final String imageFileName = json['image']?.toString() ?? '';
    final String recordId = json['id']?.toString() ?? '';
    final String image = imageFileName.isNotEmpty && recordId.isNotEmpty
        ? '$pocketBaseUrl/api/files/recipes/$recordId/$imageFileName'
        : 'https://via.placeholder.com/150';

    developer.log('Recipe JSON: $json', name: 'Recipe.fromJson');
    developer.log('Image Field: $imageFileName', name: 'Recipe.fromJson');
    developer.log('ID Field: $recordId', name: 'Recipe.fromJson');
    developer.log('Constructed Image URL: $image', name: 'Recipe.fromJson');

    try {
      return Recipe(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Resep Tanpa Nama',
        description: json['description']?.toString() ?? '',
        image: image,
        prepTime: int.tryParse(json['prepTime']?.toString() ?? '0') ?? 0,
        cookTime: double.tryParse(json['cookTime']?.toString() ?? '0') ?? 0.0,
        servings: double.tryParse(json['servings']?.toString() ?? '1') ?? 1.0,
        difficulty: json['difficulty']?.toString() ?? 'Medium',
        userId: json['user_id']?.toString(),
        categoryId: json['id_category']?.toString(),
        ingredients: (json['expand']?['ingredients'] as List<dynamic>?)
            ?.map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
            .toList() ?? [],
        steps: (json['expand']?['steps'] as List<dynamic>?)
            ?.map((item) => Step.fromJson(item as Map<String, dynamic>))
            .toList() ?? [],
        isFavorite: false, // Akan diatur oleh getFavoriteRecipes
      );
    } catch (e) {
      developer.log('Error parsing Recipe: $e', name: 'Recipe.fromJson');
      return Recipe(
        id: '',
        title: 'Error',
        description: 'Gagal memuat resep',
        image: 'https://via.placeholder.com/150',
        prepTime: 0,
        cookTime: 0.0,
        servings: 1.0,
        difficulty: 'Medium',
        ingredients: [],
        steps: [],
        isFavorite: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image.split('/').last,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'user_id': userId,
      'id_category': categoryId,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  // Menambahkan metode copyWith
  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    int? prepTime,
    double? cookTime,
    double? servings,
    String? difficulty,
    String? userId,
    String? categoryId,
    List<Ingredient>? ingredients,
    List<Step>? steps,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}