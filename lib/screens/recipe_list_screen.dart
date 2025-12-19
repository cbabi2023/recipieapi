import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController.forward();

    // Hide/show FAB on scroll
    double lastScrollOffset = 0;
    _scrollController.addListener(() {
      final currentOffset = _scrollController.offset;
      if (currentOffset > lastScrollOffset && currentOffset > 100) {
        // Scrolling down
        _fabAnimationController.reverse();
      } else if (currentOffset < lastScrollOffset) {
        // Scrolling up
        _fabAnimationController.forward();
      }
      lastScrollOffset = currentOffset;
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design considerations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = Provider.of<RecipeProvider>(context, listen: false);
          await provider.refreshRecipes(); // This resets to "all"
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification) {
              final metrics = notification.metrics;
              if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                final provider = Provider.of<RecipeProvider>(context, listen: false);
                if (!provider.isLoadingMore && provider.hasMore) {
                  provider.loadMoreRecipes();
                }
              }
            }
            return false;
          },
          child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
          // App Bar with animation
          SliverAppBar(
            expandedHeight: screenHeight * 0.15,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: Colors.deepOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Food Recipes',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: (screenWidth * 0.05).clamp(20.0, 26.0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepOrange.withValues(alpha: 0.1),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Category Chips
          Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              if (provider.categories.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              
              return SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // "All" category chip
                        _buildCategoryChip(
                          label: 'All',
                          isSelected: provider.selectedCategory == 'all',
                          onTap: () => provider.selectCategory('all'),
                        ),
                        const SizedBox(width: 8),
                        // Other category chips
                        ...provider.categories.map((category) {
                          final displayName = _formatCategoryName(category);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryChip(
                              label: displayName,
                              isSelected: provider.selectedCategory == category,
                              onTap: () => provider.selectCategory(category),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Recipe List
          Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.recipes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading delicious recipes...',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.error != null && provider.recipes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: (screenWidth * 0.045).clamp(18.0, 22.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            style: TextStyle(
                              fontSize: (screenWidth * 0.035).clamp(14.0, 16.0),
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => provider.loadRecipes(refresh: true),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (provider.recipes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No recipes found',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.045).clamp(18.0, 22.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a new recipe to get started!',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.035).clamp(14.0, 16.0),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Show loading indicator at the bottom
                      if (index == provider.recipes.length) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: provider.isLoadingMore
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.deepOrange,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      final recipe = provider.recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        index: index,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  RecipeDetailScreen(recipe: recipe),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      );
                    },
                    childCount: provider.recipes.length +
                        (provider.hasMore ? 1 : 0),
                  ),
                ),
              );
            },
          ),
        ],
          ),
        ),
      ),
      floatingActionButton: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _fabAnimationController,
                curve: Curves.elasticOut,
              ),
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                final provider = Provider.of<RecipeProvider>(context, listen: false);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AddRecipeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ).then((_) {
                  // Refresh list when returning from add screen
                  if (mounted) {
                    provider.refreshRecipes();
                  }
                });
              },
              backgroundColor: Colors.deepOrange,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add Recipe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: (screenWidth * 0.035).clamp(14.0, 16.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.deepOrange,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    // Format category name for display
    String formatted = category.replaceAll("'", "'");
    // Capitalize first letter of each word
    List<String> words = formatted.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }
    return words.join(' ');
  }
}
