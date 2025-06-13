import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer' as developer;
import '../models/recipe.dart';
import '../services/database_helper.dart';
import '../utils/platform_helper.dart';
import '../widgets/adaptive_widgets.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'category_screen.dart';
import 'tips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late TabController _tabController;
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isLoading = true;
        _loadRecipes();
      });
    });
    _loadRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipesByCategory(String category) async {
    setState(() {
      _isLoading = true;
    });

    try {
      imageCache.clear();
      imageCache.clearLiveImages();
      developer.log('Cleared image cache for category: $category', name: 'HomeScreen');

      List<Recipe> recipes = await DatabaseHelper.instance.getRecipesByCategory(category);
      if (!mounted) return;

      developer.log('Loaded ${recipes.length} recipes for category: $category', name: 'HomeScreen');
      setState(() {
        _recipes = recipes;
        _filterRecipes(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      developer.log('Error loading recipes by category: $e', name: 'HomeScreen');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      imageCache.clear();
      imageCache.clearLiveImages();
      developer.log('Cleared image cache', name: 'HomeScreen');

      List<Recipe> recipes;
      switch (_tabController.index) {
        case 0: // Terbaru
          recipes = await DatabaseHelper.instance.getNewestRecipes(limit: 4);
          break;
        case 1: // Favorit
          recipes = await DatabaseHelper.instance.getFavoriteRecipes();
          break;
        default:
          recipes = await DatabaseHelper.instance.getRecipes();
      }
      if (!mounted) return;

      if (_selectedCategory != 'Semua') {
        recipes = recipes.where((recipe) => recipe.categoryId == _selectedCategory).toList();
      }

      developer.log('Loaded ${recipes.length} recipes for tab: ${_tabController.index}', name: 'HomeScreen');
      setState(() {
        _recipes = recipes;
        _filterRecipes(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      developer.log('Error loading recipes: $e', name: 'HomeScreen');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  void _filterRecipes(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRecipes = _recipes.where((recipe) {
        final matchesQuery = query.isEmpty ||
            recipe.title.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'Semua' ||
            recipe.categoryId == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _loadRecipesByCategory(category);
    });
  }

  Widget _buildHomeContent() {
    return _isLoading
        ? const Center(child: AdaptiveProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PlatformHelper.shouldUseMaterial
                      ? TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari resep pastry...',
                            hintStyle: const TextStyle(fontFamily: 'Roboto'),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: _filterRecipes,
                        )
                      : CupertinoSearchTextField(
                          placeholder: 'Cari resep pastry...',
                          style: const TextStyle(fontFamily: 'Roboto'),
                          onChanged: _filterRecipes,
                        ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryChip('Semua', isSelected: _selectedCategory == 'Semua'),
                      _buildCategoryChip('Choux Pastry', isSelected: _selectedCategory == 'Choux Pastry'),
                      _buildCategoryChip('Croissant Pastry', isSelected: _selectedCategory == 'Croissant Pastry'),
                      _buildCategoryChip('Puff Pastry', isSelected: _selectedCategory == 'Puff Pastry'),
                      _buildCategoryChip('Short Pastry', isSelected: _selectedCategory == 'Short Pastry'),
                      _buildCategoryChip('Phyllo Pastry', isSelected: _selectedCategory == 'Phyllo Pastry'),
                      _buildCategoryChip('Danish Pastry', isSelected: _selectedCategory == 'Danish Pastry'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PlatformHelper.shouldUseMaterial
                      ? TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                          tabs: const [
                            Tab(
                              child: Text(
                                'Terbaru',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Favorit',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        )
                      : CupertinoSegmentedControl<int>(
                          children: {
                            0: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Terbaru',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                  color: _tabController.index == 0
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                              ),
                            ),
                            1: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Favorit',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                  color: _tabController.index == 1
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                              ),
                            ),
                          },
                          onValueChanged: (index) {
                            setState(() {
                              _tabController.animateTo(index);
                            });
                          },
                          groupValue: _tabController.index,
                          borderColor: Theme.of(context).primaryColor,
                          selectedColor: Theme.of(context).primaryColor,
                          unselectedColor: CupertinoColors.systemGrey5,
                        ),
                ),
                SizedBox(
                  height: 320,
                  child: _filteredRecipes.isEmpty && _searchQuery.isEmpty && _selectedCategory == 'Semua'
                      ? const Center(
                          child: Text(
                            'Tidak ada resep',
                            style: TextStyle(fontFamily: 'Roboto'),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          scrollDirection: Axis.horizontal,
                          itemCount: _filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _filteredRecipes[index];
                            final imageUrl = recipe.image;
                            return SizedBox(
                              width: 250,
                              child: Card(
                                margin: const EdgeInsets.only(right: 12.0, bottom: 12.0),
                                clipBehavior: Clip.antiAlias,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
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
                                      Stack(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Center(child: CircularProgressIndicator()),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              developer.log(
                                                'Image failed to load: URL=$imageUrl, Error=$error, StackTrace=$stackTrace',
                                                name: 'HomeScreen',
                                              );
                                              return Container(
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                                              );
                                            },
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withAlpha(153),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                recipe.difficulty,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
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
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
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
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? AppTheme.darkMutedTextColor
                                                    : Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  PlatformHelper.shouldUseMaterial
                                                      ? Icons.timer
                                                      : CupertinoIcons.time,
                                                  size: 14,
                                                  color: Theme.of(context).brightness == Brightness.dark
                                                      ? AppTheme.darkMutedTextColor
                                                      : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${recipe.prepTime + recipe.cookTime.toInt()} menit',
                                                  style: TextStyle(
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? AppTheme.darkMutedTextColor
                                                        : Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: Icon(
                                                    recipe.isFavorite
                                                        ? (PlatformHelper.shouldUseMaterial
                                                            ? Icons.favorite
                                                            : CupertinoIcons.heart_fill)
                                                        : (PlatformHelper.shouldUseMaterial
                                                            ? Icons.favorite_border
                                                            : CupertinoIcons.heart),
                                                    size: 14,
                                                    color: recipe.isFavorite
                                                        ? Theme.of(context).primaryColor
                                                        : (Theme.of(context).brightness == Brightness.dark
                                                            ? AppTheme.darkMutedTextColor
                                                            : Colors.grey[600]),
                                                  ),
                                                  onPressed: () async {
                                                    final success = await DatabaseHelper.instance.toggleFavorite(recipe.id);
                                                    if (success && mounted) {
                                                      setState(() {
                                                        recipe.isFavorite = !recipe.isFavorite;
                                                        if (_tabController.index == 1) {
                                                          _loadRecipes(); // Reload if on Favorites tab
                                                        }
                                                      });
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Gagal mengubah status favorit')),
                                                      );
                                                      developer.log('Toggle favorite failed for recipe ${recipe.id}', name: 'HomeScreen');
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kategori Pastry',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                adaptivePageRoute(
                                  builder: (context) => const CategoryScreen(category: 'Semua'),
                                ),
                              );
                            },
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(decoration: TextDecoration.none),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryItem('Croissant', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=1000', 24),
                            _buildCategoryItem('Éclair', 'https://images.unsplash.com/photo-1626803775151-61d756612f97?q=80&w=1000', 18),
                            _buildCategoryItem('Macaron', 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?q=80&w=1000', 32),
                            _buildCategoryItem('Tart', 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?q=80&w=1000', 27),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tips & Trik',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                adaptivePageRoute(
                                  builder: (context) => const TipsScreen(),
                                ),
                              );
                            },
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTipItem(
                        'Tips Membuat Adonan Puff Pastry yang Sempurna',
                        'Pelajari teknik melipat dan mendinginkan adonan untuk hasil yang berlapis-lapis.',
                        'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=1000',
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        'Teknik Dekorasi Kue Tart untuk Pemula',
                        'Cara mudah menghias kue tart dengan hasil yang profesional.',
                        'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?q=80&w=1000',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildFavoritesContent() {
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.instance.getFavoriteRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AdaptiveProgressIndicator());
        }

        if (snapshot.hasError) {
          developer.log('Favorites error: ${snapshot.error}', name: 'HomeScreen');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final favorites = snapshot.data ?? [];
        developer.log('Loaded ${favorites.length} favorite recipes', name: 'HomeScreen');

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PlatformHelper.shouldUseMaterial ? Icons.favorite : CupertinoIcons.heart,
                  size: 80,
                  color: Theme.of(context).primaryColor.withAlpha(77),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada resep favorit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tambahkan resep ke favorit dengan menekan ikon hati',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final recipe = favorites[index];
            final imageUrl = recipe.image;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
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
                        'Favorites image failed to load: URL=$imageUrl, Error=$error, StackTrace=$stackTrace',
                        name: 'HomeScreen',
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
                    PlatformHelper.shouldUseMaterial ? Icons.favorite : CupertinoIcons.heart_fill,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    final success = await DatabaseHelper.instance.toggleFavorite(recipe.id);
                    if (success && mounted) {
                      setState(() {
                        _loadRecipes(); // Reload to update favorite status
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal mengubah status favorit')),
                      );
                    }
                  },
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: _currentIndex == 2
          ? null
          : AdaptiveAppBar(
              title: 'Pastry Paradise',
              actions: [
                IconButton(
                  icon: Icon(
                    PlatformHelper.shouldUseMaterial
                        ? Icons.notifications_outlined
                        : CupertinoIcons.bell,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      adaptivePageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          _buildFavoritesContent(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AdaptiveBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationItem(
            label: 'Beranda',
            materialIcon: Icons.home,
            cupertinoIcon: CupertinoIcons.home,
          ),
          BottomNavigationItem(
            label: 'Favorit',
            materialIcon: Icons.favorite,
            cupertinoIcon: CupertinoIcons.heart,
          ),
          BottomNavigationItem(
            label: 'Profil',
            materialIcon: Icons.person,
            cupertinoIcon: CupertinoIcons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: PlatformHelper.shouldUseMaterial
          ? FilterChip(
              label: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  decoration: TextDecoration.none,
                  color: isSelected
                      ? (isDarkMode ? Colors.white : Colors.white)
                      : (isDarkMode ? Colors.white70 : Colors.black),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                _filterByCategory(label);
              },
              backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[200],
              selectedColor: AppTheme.primaryColor.withAlpha(isDarkMode ? 179 : 51),
              checkmarkColor: isDarkMode ? Colors.white : AppTheme.primaryColor,
            )
          : GestureDetector(
              onTap: () {
                _filterByCategory(label);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withAlpha(isDarkMode ? 179 : 51)
                      : (isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    decoration: TextDecoration.none,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDarkMode ? Colors.white70 : Colors.black),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryItem(String name, String image, int count) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          adaptivePageRoute(
            builder: (context) => CategoryScreen(category: name),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    developer.log(
                      'Category item image failed to load: URL=$image, Error=$error, StackTrace=$stackTrace',
                      name: 'HomeScreen',
                    );
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 30),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(179),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      '$count resep',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description, String image) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                developer.log(
                  'Tip item image failed to load: URL=$image, Error=$error, StackTrace=$stackTrace',
                  name: 'HomeScreen',
                );
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkMutedTextColor
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}