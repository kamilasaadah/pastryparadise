import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer' as developer;
import '../models/recipe.dart';
import '../services/database_helper.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart';
import 'recipe_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      imageCache.clear();
      imageCache.clearLiveImages();
      developer.log('Cleared image cache', name: 'CategoryScreen');

      final recipes = widget.category == 'Semua'
          ? await DatabaseHelper.instance.getRecipes()
          : await DatabaseHelper.instance.getRecipesByCategory(widget.category);
      final favorites = await DatabaseHelper.instance.getFavoriteRecipes();
      if (!mounted) return;

      final updatedRecipes = recipes.map((recipe) {
        final isFavorite = favorites.any((fav) => fav.id == recipe.id);
        return recipe.copyWith(isFavorite: isFavorite);
      }).toList();

      developer.log('Loaded ${updatedRecipes.length} recipes for category: ${widget.category}', name: 'CategoryScreen');
      setState(() {
        _recipes = updatedRecipes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      developer.log('Error loading recipes: $e', name: 'CategoryScreen');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  Future<void> _toggleFavorite(String recipeId) async {
    try {
      final success = await DatabaseHelper.instance.toggleFavorite(recipeId);
      if (success && mounted) {
        await _loadRecipes(); // Reload recipes to sync favorite status
      }
    } catch (e) {
      if (mounted) {
        developer.log('Error toggling favorite: $e', name: 'CategoryScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle favorite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: widget.category == 'Semua' ? 'Semua Kategori' : widget.category,
        leading: IconButton(
          icon: Icon(
            PlatformHelper.shouldUseMaterial ? Icons.arrow_back : CupertinoIcons.back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: AdaptiveProgressIndicator())
          : _recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PlatformHelper.shouldUseMaterial
                            ? Icons.restaurant_menu
                            : CupertinoIcons.square_list,
                        size: 80,
                        color: Theme.of(context).primaryColor.withAlpha(77),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada resep di kategori ini',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Coba kategori lain atau periksa kembali nanti.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    final imageUrl = recipe.image;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              developer.log(
                                'Image failed to load: URL=$imageUrl, Error=$error, StackTrace=$stackTrace',
                                name: 'CategoryScreen',
                              );
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          recipe.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          recipe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            recipe.isFavorite
                                ? (PlatformHelper.shouldUseMaterial
                                    ? Icons.favorite
                                    : CupertinoIcons.heart_fill)
                                : (PlatformHelper.shouldUseMaterial
                                    ? Icons.favorite_border
                                    : CupertinoIcons.heart),
                            color: recipe.isFavorite ? Colors.red : Colors.grey[600],
                          ),
                          onPressed: () => _toggleFavorite(recipe.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            adaptivePageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}