import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';
import '../widgets/review_card.dart';
import '../services/database_helper.dart';
import '../models/ingredient.dart';
import '../models/step.dart' as model;

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  List<Review> _reviews = [];
  List<Ingredient> _ingredients = [];
  List<model.Step> _steps = [];
  bool _isLoadingReviews = true;
  bool _isLoadingIngredients = true;
  bool _isLoadingSteps = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isFavorite = widget.recipe.isFavorite;
    _loadReviews();
    _loadIngredients();
    _loadSteps();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await DatabaseHelper.instance.getReviewsForRecipe(widget.recipe.id);
      debugPrint('Loaded reviews for recipe ${widget.recipe.id}: ${reviews.map((r) => '${r.id}: ${r.comment}').toList()}');
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews for recipe ${widget.recipe.id}: $e');
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await DatabaseHelper.instance.getIngredientsForRecipe(widget.recipe.id);
      if (mounted) {
        setState(() {
          _ingredients = ingredients;
          _isLoadingIngredients = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingIngredients = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading ingredients: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _loadSteps() async {
    try {
      debugPrint('Loading steps for recipe ID: ${widget.recipe.id}');
      final steps = await DatabaseHelper.instance.getStepsForRecipe(widget.recipe.id);
      debugPrint('Loaded steps count: ${steps.length} - Steps: ${steps.map((s) => '${s.stepNumber}: ${s.description}').toList()}');
      if (mounted) {
        final uniqueSteps = steps.toSet().toList()..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
        setState(() {
          _steps = uniqueSteps;
          _isLoadingSteps = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading steps: $e');
      if (mounted) {
        setState(() {
          _isLoadingSteps = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading steps: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    try {
      final success = await DatabaseHelper.instance.toggleFavorite(widget.recipe.id);
      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          widget.recipe.isFavorite = _isFavorite;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah status favorit')),
        );
        debugPrint('Toggle favorite failed for recipe ${widget.recipe.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling favorite: $e')),
        );
        debugPrint('Error toggling favorite: $e');
      }
    }
  }

  void _refreshReviews() {
    setState(() {
      _isLoadingReviews = true;
    });
    _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'recipe_image_${widget.recipe.id}',
                    child: Image.network(
                      widget.recipe.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.recipe.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            Icons.access_time,
                            'Prep',
                            '${widget.recipe.prepTime} min',
                          ),
                          _buildInfoItem(
                            Icons.whatshot,
                            'Cook',
                            '${widget.recipe.cookTime.toInt()} min',
                          ),
                          _buildInfoItem(
                            Icons.restaurant,
                            'Servings',
                            '${widget.recipe.servings}',
                          ),
                          _buildInfoItem(
                            Icons.signal_cellular_alt,
                            'Difficulty',
                            widget.recipe.difficulty,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppTheme.primaryColor,
                        tabs: const [
                          Tab(text: 'Ingredients'),
                          Tab(text: 'Steps'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIngredientsTab(),
                    _buildStepsTab(),
                    _buildReviewsTab(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.play_arrow),
        onPressed: () {
          // Start cooking mode
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsTab() {
    if (_isLoadingIngredients) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_ingredients.isEmpty) {
      return const Center(child: Text('No ingredients available'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepsTab() {
    if (_isLoadingSteps) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_steps.isEmpty) {
      return const Center(child: Text('No steps available'));
    }
    final sortedSteps = List<model.Step>.from(_steps)..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSteps.length,
      itemBuilder: (context, index) {
        final step = sortedSteps[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddReviewDialog() async {
    final TextEditingController commentController = TextEditingController();
    double rating = 0.0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Your Review'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      value: rating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: rating.toStringAsFixed(1),
                      onChanged: (newValue) {
                        setState(() {
                          rating = newValue;
                        });
                      },
                    ),
                    Text(
                      'Rating: ${rating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(labelText: 'Comment'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (rating > 0 && commentController.text.isNotEmpty) {
                      final success = await DatabaseHelper.instance.createReview(widget.recipe.id, rating, commentController.text);
                      if (success && mounted) {
                        _refreshReviews();
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a rating and add a comment')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    debugPrint('Rendering reviews: ${_reviews.length} items');
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review,
              size: 64,
              color: Color.fromARGB(255, 189, 189, 189),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showAddReviewDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Be the first to review'),
            ),
            ElevatedButton(
              onPressed: () {
                _loadReviews();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reloaded reviews: ${_reviews.length}')),
                );
              },
              child: const Text('Force Reload'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return ReviewCard(
                review: review,
                onDelete: () => _deleteReview(review.id),
                onEdit: () => _refreshReviews(),
                onRefresh: _refreshReviews,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _showAddReviewDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Add Your Review'),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteReview(String reviewId) async {
    final success = await DatabaseHelper.instance.deleteReview(reviewId);
    if (success && mounted) {
      await _loadReviews();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete review')),
        );
      }
    }
  }
}