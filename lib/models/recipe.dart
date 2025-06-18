import 'dart:developer' as developer;
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
      defaultValue: 'http://127.0.0.1:8090',
    );
    final String imageFileName = json['image']?.toString() ?? '';
    final String recordId = json['id']?.toString() ?? '';
    final String image = imageFileName.isNotEmpty && recordId.isNotEmpty
        ? '$pocketBaseUrl/api/files/recipes/$recordId/$imageFileName'
        : 'https://via.placeholder.com/150';

    // Debug logging
    developer.log('=== RECIPE JSON DEBUG ===', name: 'Recipe.fromJson');
    developer.log('Title: ${json['title']}', name: 'Recipe.fromJson');
    developer.log('Description: ${json['description']}', name: 'Recipe.fromJson');
    developer.log('Difficulty RAW: ${json['difficulty']}', name: 'Recipe.fromJson');

    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Resep Tanpa Nama',
      description: json['description']?.toString() ?? '',
      image: image,
      prepTime: int.tryParse(json['prepTime']?.toString() ?? '0') ?? 0,
      cookTime: double.tryParse(json['cookTime']?.toString() ?? '0') ?? 0.0,
      servings: double.tryParse(json['servings']?.toString() ?? '1') ?? 1.0,
      difficulty: json['difficulty']?.toString() ?? 'Unknown', // SAMA PERSIS SEPERTI DESCRIPTION!
      userId: json['user_id']?.toString(),
      categoryId: json['id_category']?.toString(),
      ingredients: (json['expand']?['ingredients'] as List<dynamic>?)
          ?.map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      steps: (json['expand']?['steps'] as List<dynamic>?)
          ?.map((item) => model_step.Step.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      isFavorite: false,
    );
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

  // Helper methods untuk styling (opsional)
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Icons.sentiment_satisfied;
      case 'Medium':
        return Icons.sentiment_neutral;
      case 'Hard':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}
