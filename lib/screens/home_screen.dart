// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/recipe.dart';
import '../models/category.dart';
import '../services/database_helper.dart';
import '../widgets/adaptive_widgets.dart';
import '../theme/app_theme.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'category_screen.dart';
import 'favorites_screen.dart';
import 'articles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _currentIndex = 0;
  
  // Carousel controller
  late PageController _carouselController;
  int _currentCarouselIndex = 1; // Start with middle slide
  
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _carouselController = PageController(initialPage: 1, viewportFraction: 0.8);
    _loadData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _carouselController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load recipes and categories in parallel
      final results = await Future.wait([
        DatabaseHelper.instance.getNewestRecipes(limit: 20),
        DatabaseHelper.instance.getCategories(),
      ]);

      if (!mounted) return;

      setState(() {
        _recipes = results[0] as List<Recipe>;
        _categories = results[1] as List<Category>;
        _filteredRecipes = _recipes;
        _isLoading = false;
      });

      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _cardAnimationController.forward();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading data: $e');
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
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchQuery = '';
        _filteredRecipes = _recipes;
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      final searchResults = await DatabaseHelper.instance.searchRecipes(query);
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

  Widget _buildGradientHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode ? [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.6),
            Colors.deepOrange.withOpacity(0.4),
          ] : [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
            Colors.deepOrange.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isDarkMode ? 0.02 : 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang! 👋',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Text(
                            'Pastry Paradise',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarWithAccent() {
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
          // Icon search dengan background
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 18,
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
                hintText: 'Cari resep pastry favorit...',
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
              onChanged: _performSearch,
            ),
          ),
          // Clear button
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                size: 20,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final carouselItems = [
      {
        'title': 'Buat Pastry\nTerbaik! 🥐',
        'subtitle': 'Resep premium untuk hasil sempurna',
        'gradient': isDarkMode 
            ? [AppTheme.primaryColor.withOpacity(0.8), Colors.orange.withOpacity(0.8)]
            : [AppTheme.primaryColor, Colors.orange],
        'icon': Icons.cake,
      },
      {
        'title': 'Pastry Paradise\nAwaits! ✨',
        'subtitle': 'Temukan surga pastry di sini',
        'gradient': isDarkMode 
            ? [Colors.purple.withOpacity(0.8), Colors.pink.withOpacity(0.8)]
            : [Colors.purple, Colors.pink],
        'icon': Icons.star,
      },
      {
        'title': 'Master Chef\nSecrets! 👨‍🍳',
        'subtitle': 'Tips dan trik dari para ahli',
        'gradient': isDarkMode 
            ? [Colors.teal.withOpacity(0.8), Colors.cyan.withOpacity(0.8)]
            : [Colors.teal, Colors.cyan],
        'icon': Icons.local_dining,
      },
    ];

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 30),
      child: PageView.builder(
        controller: _carouselController,
        onPageChanged: (index) {
          setState(() {
            _currentCarouselIndex = index;
          });
        },
        itemCount: carouselItems.length,
        itemBuilder: (context, index) {
          final item = carouselItems[index];
          final isCenter = index == _currentCarouselIndex;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: isCenter ? 0 : 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item['gradient'] as List<Color>,
              ),
              boxShadow: isCenter ? [
                BoxShadow(
                  color: (item['gradient'] as List<Color>)[0].withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ] : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // Handle carousel item tap
                },
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(isDarkMode ? 0.02 : 0.05),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: Colors.white,
                            size: isCenter ? 40 : 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCenter ? 22 : 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['subtitle'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isCenter ? 14 : 12,
                              fontWeight: FontWeight.w500,
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
        },
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final theme = Theme.of(context);
    
    // Fallback categories jika database kosong
    final fallbackCategories = [
      {
        'id': 'choux',
        'name': 'Choux Pastry',
        'image': 'https://images.unsplash.com/photo-1626803775151-61d756612f97?q=80&w=1000',
        'icon': Icons.cake,
        'color': Colors.orange,
      },
      {
        'id': 'croissant',
        'name': 'Croissant Pastry',
        'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=1000',
        'icon': Icons.bakery_dining,
        'color': Colors.amber,
      },
      {
        'id': 'puff',
        'name': 'Puff Pastry',
        'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=1000',
        'icon': Icons.pie_chart,
        'color': Colors.brown,
      },
      {
        'id': 'short',
        'name': 'Short Pastry',
        'image': 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?q=80&w=1000',
        'icon': Icons.cookie,
        'color': Colors.pink,
      },
      {
        'id': 'phyllo',
        'name': 'Phyllo Pastry',
        'image': 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?q=80&w=1000',
        'icon': Icons.layers,
        'color': Colors.purple,
      },
      {
        'id': 'danish',
        'name': 'Danish Pastry',
        'image': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=1000',
        'icon': Icons.local_dining,
        'color': Colors.teal,
      },
    ];

    // Map category images untuk database categories
    final categoryImages = {
      'Choux Pastry': 'https://images.unsplash.com/photo-1626803775151-61d756612f97?q=80&w=1000',
      'Croissant Pastry': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=1000',
      'Puff Pastry': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=1000',
      'Short Pastry': 'https://images.unsplash.com/photo-1464305795204-6f5bbfc7fb81?q=80&w=1000',
      'Phyllo Pastry': 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?q=80&w=1000',
      'Danish Pastry': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=1000',
    };

    final categoryIcons = {
      'Choux Pastry': Icons.cake,
      'Croissant Pastry': Icons.bakery_dining,
      'Puff Pastry': Icons.pie_chart,
      'Short Pastry': Icons.cookie,
      'Phyllo Pastry': Icons.layers,
      'Danish Pastry': Icons.local_dining,
    };

    final categoryColors = {
      'Choux Pastry': Colors.orange,
      'Croissant Pastry': Colors.amber,
      'Puff Pastry': Colors.brown,
      'Short Pastry': Colors.pink,
      'Phyllo Pastry': Colors.purple,
      'Danish Pastry': Colors.teal,
    };

    // Gunakan database categories jika ada, jika tidak gunakan fallback
    final categoriesToShow = _categories.isNotEmpty ? _categories : [];
    final showFallback = _categories.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori Pastry 🥐',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
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
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: showFallback ? 6 : (categoriesToShow.length > 6 ? 6 : categoriesToShow.length),
            itemBuilder: (context, index) {
              if (showFallback) {
                // Gunakan fallback categories
                final category = fallbackCategories[index];
                return _buildCategoryCard(
                  category['name'] as String,
                  category['id'] as String,
                  category['image'] as String,
                  category['icon'] as IconData,
                  category['color'] as Color,
                  index,
                );
              } else {
                // Gunakan database categories
                final category = categoriesToShow[index];
                final image = categoryImages[category.title] ?? 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=1000';
                final icon = categoryIcons[category.title] ?? Icons.cake;
                final color = categoryColors[category.title] ?? Colors.orange;
                
                return _buildCategoryCard(
                  category.title,
                  category.id,
                  image,
                  icon,
                  color,
                  index,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String name, String categoryId, String image, IconData icon, Color color, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            30 * (1 - _cardAnimationController.value) * ((index % 3) + 1),
          ),
          child: Opacity(
            opacity: _cardAnimationController.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isDarkMode ? 0.2 : 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      adaptivePageRoute(
                        builder: (context) => CategoryScreen(category: categoryId),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: color.withOpacity(isDarkMode ? 0.2 : 0.3),
                                child: Icon(
                                  icon,
                                  size: 40,
                                  color: Colors.white,
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
                                  Colors.black.withOpacity(isDarkMode ? 0.4 : 0.3),
                                  Colors.black.withOpacity(isDarkMode ? 0.8 : 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLatestRecipesSection() {
    final theme = Theme.of(context);
    final latestRecipes = _searchQuery.isEmpty ? _recipes.take(4).toList() : _filteredRecipes.take(4).toList();

    if (latestRecipes.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'Tidak ada resep ditemukan' : 'Tidak ada hasil pencarian',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _searchQuery.isEmpty ? 'Coba muat ulang halaman' : 'Coba kata kunci lain',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isEmpty ? 'Resep Terbaru ✨' : 'Hasil Pencarian 🔍',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              if (_searchQuery.isEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      adaptivePageRoute(
                        builder: (context) => const CategoryScreen(category: 'Semua'),
                      ),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: latestRecipes.length,
            itemBuilder: (context, index) {
              return _buildEnhancedRecipeCard(latestRecipes[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedRecipeCard(Recipe recipe, int index) {
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
              width: 220,
              margin: const EdgeInsets.only(right: 16),
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
                  child: Column(
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
                                    onTap: () async {
                                      final success = await DatabaseHelper.instance.toggleFavorite(recipe.id);
                                      if (success && mounted) {
                                        setState(() {
                                          recipe.isFavorite = !recipe.isFavorite;
                                        });
                                        _showSuccessSnackBar(
                                          recipe.isFavorite 
                                              ? 'Ditambahkan ke favorit' 
                                              : 'Dihapus dari favorit'
                                        );
                                      } else if (mounted) {
                                        _showErrorSnackBar('Gagal mengubah status favorit');
                                      }
                                    },
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Content
          _isLoading
              ? const Center(child: AdaptiveProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGradientHeader(),
                          _buildSearchBarWithAccent(),
                          if (_searchQuery.isEmpty) ...[
                            _buildCarousel(),
                            _buildCategoriesGrid(),
                            const SizedBox(height: 30),
                          ],
                          _buildLatestRecipesSection(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
          // Favorites Screen
          const FavoritesScreen(),
          // Articles Screen
          const ArticlesScreen(),
          // Profile Screen
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
            label: 'Artikel',
            materialIcon: Icons.article,
            cupertinoIcon: CupertinoIcons.doc_text,
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
}
