// ignore_for_file: deprecated_member_use

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
  String _selectedView = 'grid'; // 'grid' or 'list'

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

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return _buildRecipeCard(recipe, isGrid: true);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recipes.length,
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return _buildRecipeCard(recipe, isGrid: false);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe, {required bool isGrid}) {
    final imageUrl = recipe.image;
    
    if (isGrid) {
      return Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              adaptivePageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          developer.log(
                            'Image failed to load: URL=$imageUrl, Error=$error',
                            name: 'CategoryScreen',
                          );
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Favorite Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            recipe.isFavorite
                                ? (PlatformHelper.shouldUseMaterial
                                    ? Icons.favorite
                                    : CupertinoIcons.heart_fill)
                                : (PlatformHelper.shouldUseMaterial
                                    ? Icons.favorite_border
                                    : CupertinoIcons.heart),
                            color: recipe.isFavorite ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () => _toggleFavorite(recipe.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          recipe.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // List View Card
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              adaptivePageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.grey,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Favorite Button
                IconButton(
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
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              // ignore: duplicate_ignore
              // ignore: deprecated_member_use
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PlatformHelper.shouldUseMaterial
                  ? Icons.restaurant_menu
                  : CupertinoIcons.square_list,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Resep',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada resep di kategori ini.\nCoba kategori lain atau periksa kembali nanti.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
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
        actions: [
          if (!_isLoading && _recipes.isNotEmpty)
            IconButton(
              icon: Icon(
                _selectedView == 'grid'
                    ? (PlatformHelper.shouldUseMaterial ? Icons.view_list : CupertinoIcons.list_bullet)
                    : (PlatformHelper.shouldUseMaterial ? Icons.grid_view : CupertinoIcons.grid),
              ),
              onPressed: () {
                setState(() {
                  _selectedView = _selectedView == 'grid' ? 'list' : 'grid';
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AdaptiveProgressIndicator())
          : _recipes.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Recipe Count
                    if (_recipes.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          '${_recipes.length} resep ditemukan',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    // Content
                    Expanded(
                      child: _selectedView == 'grid' ? _buildGridView() : _buildListView(),
                    ),
                  ],
                ),
    );
  }
}