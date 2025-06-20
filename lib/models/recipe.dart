import 'package:flutter/material.dart';
import 'ingredient.dart';
import 'step.dart' as model_step;

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
  final List<model_step.Step> steps;
  bool isFavorite;
  final double averageRating;
  final int reviewCount;

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
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    const String pocketBaseUrl = String.fromEnvironment(
      'POCKETBASE_URL',
      defaultValue: 'http://127.0.0.1:8090',
    );
    final String imageFileName = json['image']?.toString() ?? '';
    final String recordId = json['id']?.toString() ?? '';
    final String image = imageFileName.isNotEmpty && recordId.isNotEmpty
        ? '$pocketBaseUrl/api/files/recipes/$recordId/$imageFileName'
        : 'https://via.placeholder.com/150';

    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Resep Tanpa Nama',
      description: json['description']?.toString() ?? '',
      image: image,
      prepTime: int.tryParse(json['prepTime']?.toString() ?? '0') ?? 0,
      cookTime: double.tryParse(json['cookTime']?.toString() ?? '0') ?? 0.0,
      servings: double.tryParse(json['servings']?.toString() ?? '1') ?? 1.0,
      difficulty: json['difficulity']?.toString() ?? 'Unknown',
      userId: json['user_id']?.toString(),
      categoryId: json['id_category']?.toString(),
      ingredients: (json['expand']?['ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      steps: (json['expand']?['steps'] as List<dynamic>?)
          ?.map((item) => model_step.Step.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      isFavorite: false,
      averageRating: double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
    );
  }

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
    List<model_step.Step>? steps,
    bool? isFavorite,
    double? averageRating,
    int? reviewCount,
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
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}
