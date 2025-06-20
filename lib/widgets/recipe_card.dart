// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import 'star_rating.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    // Debug logging
    if (kDebugMode) {
      print('=== RECIPE CARD DEBUG ===');
      print('Recipe: ${recipe.title}');
      print('Average Rating: ${recipe.averageRating}');
      print('Review Count: ${recipe.reviewCount}');
    }
    
    // TEMPORARY: Gunakan dummy rating jika tidak ada data real
    // Hapus ini setelah data real tersedia
    double displayRating = recipe.averageRating;
    int displayReviewCount = recipe.reviewCount;
    
    // Jika tidak ada rating real, gunakan dummy berdasarkan nama resep
    if (displayRating == 0.0 && displayReviewCount == 0) {
      if (recipe.title.toLowerCase().contains('apple')) {
        displayRating = 4.3;
        displayReviewCount = 12;
      } else if (recipe.title.toLowerCase().contains('baklava')) {
        displayRating = 4.7;
        displayReviewCount = 8;
      } else if (recipe.title.toLowerCase().contains('cinnamon')) {
        displayRating = 4.5;
        displayReviewCount = 15;
      } else {
        displayRating = 4.0;
        displayReviewCount = 5;
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(right: 12.0, bottom: 12.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  recipe.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported, 
                        size: 50,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Recipe.getDifficultyColor(recipe.difficulty),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Recipe.getDifficultyIcon(recipe.difficulty),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // ⭐ RATING SECTION - SELALU TAMPIL
                  StarRating(
                    rating: displayRating,
                    size: 14,
                    showRatingText: true,
                    reviewCount: displayReviewCount,
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.timer, 
                        size: 14, 
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime + recipe.cookTime.toInt()} menit',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        recipe.isFavorite ? Icons.favorite : Icons.favorite_border, 
                        size: 14, 
                        color: recipe.isFavorite 
                            ? AppTheme.primaryColor 
                            : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
