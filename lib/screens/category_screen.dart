// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer' as developer;
import '../models/recipe.dart';
import '../models/category.dart';
import '../services/database_helper.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category; // This can be category ID or "Semua"

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  List<Category> _categories = [];
  String _categoryTitle = '';
  bool _isLoading = true;
  String _selectedView = 'grid'; // 'grid' or 'list'
  String _searchQuery = '';
  String _selectedCategoryFilter = 'Semua'; // For additional filtering
  
  late AnimationController _cardAnimationController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      imageCache.clear();
      imageCache.clearLiveImages();
      developer.log('Cleared image cache', name: 'CategoryScreen');

      // Load categories and recipes in parallel
      final results = await Future.wait([
        DatabaseHelper.instance.getCategories(),
        _loadRecipesForCategory(),
      ]);

      if (!mounted) return;

      final categories = results[0] as List<Category>;
      final recipes = results[1] as List<Recipe>;

      // Set category title
      if (widget.category == 'Semua') {
        _categoryTitle = 'Semua Kategori';
      } else {
        final category = categories.firstWhere(
          (cat) => cat.id == widget.category,
          orElse: () => Category(id: widget.category, title: widget.category),
        );
        _categoryTitle = category.title;
      }

      developer.log('Loaded ${recipes.length} recipes for category: ${widget.category}', name: 'CategoryScreen');
      
      setState(() {
        _categories = categories;
        _allRecipes = recipes;
        _filteredRecipes = recipes;
        _isLoading = false;
      });

      // Start animations
      _cardAnimationController.forward();
    } catch (e) {
      if (!mounted) return;
      developer.log('Error loading data: $e', name: 'CategoryScreen');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading data: $e');
    }
  }

  Future<List<Recipe>> _loadRecipesForCategory() async {
    if (widget.category == 'Semua') {
      return await DatabaseHelper.instance.getRecipes();
    } else {
      return await DatabaseHelper.instance.getRecipesByCategory(widget.category);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      List<Recipe> searchResults;
      
      if (query.isEmpty) {
        // If no search query, show recipes based on current category filter
        if (_selectedCategoryFilter == 'Semua') {
          searchResults = _allRecipes;
        } else {
          searchResults = _allRecipes.where((recipe) {
            return recipe.categoryId == _selectedCategoryFilter;
          }).toList();
        }
      } else {
        // Search within current category context
        List<Recipe> recipesToSearch;
        if (widget.category == 'Semua') {
          // If we're in "Semua" category, search all recipes
          recipesToSearch = await DatabaseHelper.instance.searchRecipes(query);
        } else {
          // If we're in specific category, search within that category
          final allSearchResults = await DatabaseHelper.instance.searchRecipes(query);
          recipesToSearch = allSearchResults.where((recipe) {
            return recipe.categoryId == widget.category;
          }).toList();
        }
        
        // Apply additional category filter if selected
        if (_selectedCategoryFilter != 'Semua') {
          searchResults = recipesToSearch.where((recipe) {
            return recipe.categoryId == _selectedCategoryFilter;
          }).toList();
        } else {
          searchResults = recipesToSearch;
        }
      }

      if (!mounted) return;

      setState(() {
        _filteredRecipes = searchResults;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error searching recipes: $e');
    }
  }

  void _applyFilter(String categoryId) {
    setState(() {
      _selectedCategoryFilter = categoryId;
    });
    
    // Re-apply search with new filter
    _performSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredRecipes = _selectedCategoryFilter == 'Semua' 
          ? _allRecipes 
          : _allRecipes.where((recipe) => recipe.categoryId == _selectedCategoryFilter).toList();
    });
  }

  Future<void> _toggleFavorite(String recipeId) async {
    try {
      developer.log('Toggling favorite for recipe: $recipeId', name: 'CategoryScreen');
      final success = await DatabaseHelper.instance.toggleFavorite(recipeId);
      if (success && mounted) {
        // Update the recipe in both lists
        setState(() {
          _allRecipes = _allRecipes.map((recipe) {
            if (recipe.id == recipeId) {
              return recipe.copyWith(isFavorite: !recipe.isFavorite);
            }
            return recipe;
          }).toList();
          
          _filteredRecipes = _filteredRecipes.map((recipe) {
            if (recipe.id == recipeId) {
              return recipe.copyWith(isFavorite: !recipe.isFavorite);
            }
            return recipe;
          }).toList();
        });
        
        _showSuccessSnackBar('Favorite status updated');
      } else {
        developer.log('Toggle favorite failed', name: 'CategoryScreen');
      }
    } catch (e) {
      if (mounted) {
        developer.log('Error toggling favorite: $e', name: 'CategoryScreen');
        _showErrorSnackBar('Failed to toggle favorite: $e');
      }
    }
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search button with pink background
          Container(
            margin: const EdgeInsets.all(6),
            child: Material(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _performSearch, // Search only when button is pressed
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          // TextField
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Cari resep pastry...',
                hintStyle: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onSubmitted: (_) => _performSearch(), // Also search when Enter is pressed
              // Remove onChanged - no more auto search!
            ),
          ),
          // Clear button
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                size: 20,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              onPressed: _clearSearch,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Add "Semua" option to the beginning
    final allCategories = [
      Category(id: 'Semua', title: 'Semua'),
      ..._categories,
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Filter Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isSelected = _selectedCategoryFilter == category.id;
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      category.title,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      _applyFilter(category.id);
                    },
                    backgroundColor: isDarkMode ? theme.cardColor : Colors.grey[100],
                    selectedColor: AppTheme.primaryColor,
                    checkmarkColor: Colors.white,
                    elevation: isSelected ? 4 : 0,
                    shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    final theme = Theme.of(context);
    
    String headerText;
    if (_searchQuery.isNotEmpty) {
      headerText = 'Hasil pencarian "$_searchQuery"';
    } else if (_selectedCategoryFilter != 'Semua') {
      final selectedCategory = _categories.firstWhere(
        (cat) => cat.id == _selectedCategoryFilter,
        orElse: () => Category(id: _selectedCategoryFilter, title: _selectedCategoryFilter),
      );
      headerText = 'Kategori ${selectedCategory.title}';
    } else {
      headerText = _categoryTitle;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerText,
                  style: TextStyle(
                    color: theme.textTheme.titleMedium?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_filteredRecipes.length} resep ditemukan',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_filteredRecipes.isNotEmpty)
            IconButton(
              icon: Icon(
                _selectedView == 'grid'
                    ? (PlatformHelper.shouldUseMaterial ? Icons.view_list : CupertinoIcons.list_bullet)
                    : (PlatformHelper.shouldUseMaterial ? Icons.grid_view : CupertinoIcons.grid),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _selectedView = _selectedView == 'grid' ? 'list' : 'grid';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        return _buildEnhancedRecipeCard(recipe, index);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildEnhancedRecipeCard(recipe, index, isListView: true),
        );
      },
    );
  }

  // Enhanced recipe card that matches home screen design
  Widget _buildEnhancedRecipeCard(Recipe recipe, int index, {bool isListView = false}) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            50 * (1 - _cardAnimationController.value) * (index % 3 + 1),
          ),
          child: Opacity(
            opacity: _cardAnimationController.value,
            child: Container(
              width: isListView ? double.infinity : 220,
              height: isListView ? 120 : null,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      adaptivePageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  child: isListView ? _buildListCard(recipe, theme, isDarkMode) : _buildGridCard(recipe, theme, isDarkMode),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridCard(Recipe recipe, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                recipe.image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 140,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  developer.log(
                    'Image failed to load: URL=${recipe.image}, Error=$error',
                    name: 'CategoryScreen',
                  );
                  return Container(
                    height: 140,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getDifficultyIcon(recipe.difficulty),
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: theme.textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTime + recipe.cookTime.toInt()} min',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _toggleFavorite(recipe.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: recipe.isFavorite 
                              ? Colors.red.withOpacity(0.1)
                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          recipe.isFavorite 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          size: 16,
                          color: recipe.isFavorite 
                              ? Colors.red 
                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(Recipe recipe, ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
          child: Image.network(
            recipe.image,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 120,
                height: 120,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 40),
              );
            },
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
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
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(recipe.difficulty),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe.difficulty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTime + recipe.cookTime.toInt()} min',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _toggleFavorite(recipe.id),
                      child: Icon(
                        recipe.isFavorite 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                        size: 20,
                        color: recipe.isFavorite 
                            ? Colors.red 
                            : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'mudah':
        return Icons.sentiment_satisfied;
      case 'medium':
      case 'sedang':
        return Icons.sentiment_neutral;
      case 'hard':
      case 'sulit':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'mudah':
        return Colors.green;
      case 'medium':
      case 'sedang':
        return Colors.orange;
      case 'hard':
      case 'sulit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    String emptyMessage;
    String emptySubtitle;
    
    if (_searchQuery.isNotEmpty) {
      emptyMessage = 'Tidak Ada Hasil';
      emptySubtitle = 'Tidak ditemukan resep dengan kata kunci "$_searchQuery".\nCoba kata kunci lain.';
    } else if (_selectedCategoryFilter != 'Semua') {
      final selectedCategory = _categories.firstWhere(
        (cat) => cat.id == _selectedCategoryFilter,
        orElse: () => Category(id: _selectedCategoryFilter, title: _selectedCategoryFilter),
      );
      emptyMessage = 'Belum Ada Resep';
      emptySubtitle = 'Tidak ada resep di kategori ${selectedCategory.title}.\nCoba kategori lain.';
    } else {
      emptyMessage = 'Belum Ada Resep';
      emptySubtitle = 'Tidak ada resep di kategori ini.\nCoba kategori lain atau periksa kembali nanti.';
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty 
                    ? Icons.search_off
                    : Icons.restaurant_menu,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            if (_searchQuery.isNotEmpty || _selectedCategoryFilter != 'Semua') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategoryFilter = 'Semua';
                    _filteredRecipes = _allRecipes;
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Reset Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: _categoryTitle.isNotEmpty ? _categoryTitle : 'Kategori',
        leading: IconButton(
          icon: Icon(
            PlatformHelper.shouldUseMaterial ? Icons.arrow_back : CupertinoIcons.back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: AdaptiveProgressIndicator())
          : Column(
              children: [
                // Search Bar
                _buildSearchBar(),
                
                // Category Filters (only show if we have categories and we're in "Semua" mode or have multiple categories)
                if (_categories.isNotEmpty && (widget.category == 'Semua' || _categories.length > 1))
                  _buildCategoryFilters(),
                
                // Results Header
                if (_filteredRecipes.isNotEmpty)
                  _buildResultsHeader(),
                
                // Content
                Expanded(
                  child: _filteredRecipes.isEmpty
                      ? _buildEmptyState()
                      : _selectedView == 'grid' 
                          ? _buildGridView() 
                          : _buildListView(),
                ),
              ],
            ),
    );
  }
}
