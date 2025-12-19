import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class RecipeRepository {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService.instance;
  static const int pageSize = 10;

  // Get recipes with pagination (combines API and local)
  // API products show first, then local recipes
  Future<Map<String, dynamic>> getRecipes({
    int page = 1,
    bool loadMore = false,
    String? category,
  }) async {
    try {
      final List<Recipe> allRecipes = [];
      
      // Fetch API recipes first (default products)
      final apiPage = loadMore ? page : 1;
      final apiRecipes = await _apiService.fetchRecipes(
        limit: pageSize * apiPage,
        offset: 0,
        category: category,
      );
      
      // Add API recipes first (they are the default products)
      allRecipes.addAll(apiRecipes);
      
      // Then add local recipes (user-added products) - filter by category if specified
      final localRecipes = await _databaseService.getAllRecipes();
      if (category != null && category.isNotEmpty && category != 'all') {
        final filteredLocal = localRecipes.where((recipe) => 
          recipe.category?.toLowerCase() == category.toLowerCase()
        ).toList();
        allRecipes.addAll(filteredLocal);
      } else {
        allRecipes.addAll(localRecipes);
      }

      // Check if there are more recipes to load
      final hasMore = apiRecipes.length >= pageSize * apiPage;

      return {
        'recipes': allRecipes,
        'hasMore': hasMore,
        'currentPage': page,
      };
    } catch (e) {
      // If API fails, return only local recipes (filtered if category specified)
      final localRecipes = await _databaseService.getAllRecipes();
      List<Recipe> filteredRecipes = localRecipes;
      if (category != null && category.isNotEmpty && category != 'all') {
        filteredRecipes = localRecipes.where((recipe) => 
          recipe.category?.toLowerCase() == category.toLowerCase()
        ).toList();
      }
      return {
        'recipes': filteredRecipes,
        'hasMore': false,
        'currentPage': page,
      };
    }
  }

  // Load more recipes (for infinite scroll)
  Future<List<Recipe>> loadMoreRecipes(int currentPage, {String? category}) async {
    try {
      final apiRecipes = await _apiService.fetchRecipes(
        limit: pageSize,
        offset: currentPage * pageSize,
        category: category,
      );
      return apiRecipes;
    } catch (e) {
      return [];
    }
  }

  // Get categories from API
  Future<List<String>> getCategories() async {
    try {
      return await _apiService.fetchCategories();
    } catch (e) {
      // Return default categories if API fails
      return ['electronics', "men's clothing", "women's clothing", 'jewelery'];
    }
  }

  // Add a new recipe to local database
  Future<int> addRecipe(Recipe recipe) async {
    final recipeWithSource = recipe.copyWith(source: 'LOCAL');
    return await _databaseService.insertRecipe(recipeWithSource);
  }

  // Update a local recipe
  Future<int> updateRecipe(Recipe recipe) async {
    if (recipe.source == 'LOCAL' && recipe.id != null) {
      return await _databaseService.updateRecipe(recipe);
    }
    throw Exception('Cannot update API recipes');
  }

  // Delete a local recipe
  Future<int> deleteRecipe(int id) async {
    return await _databaseService.deleteRecipe(id);
  }

  // Get only local recipes
  Future<List<Recipe>> getLocalRecipes() async {
    return await _databaseService.getAllRecipes();
  }
}
