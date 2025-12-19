import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class RecipeRepository {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService.instance;
  static const int pageSize = 10;

  // Get recipes with pagination (combines API and local)
  Future<Map<String, dynamic>> getRecipes({
    int page = 1,
    bool loadMore = false,
  }) async {
    try {
      final List<Recipe> allRecipes = [];
      
      // Always load local recipes first (they're usually fewer)
      final localRecipes = await _databaseService.getAllRecipes();
      allRecipes.addAll(localRecipes);

      // Calculate how many API recipes to fetch
      final apiPage = loadMore ? page : 1;
      final apiRecipes = await _apiService.fetchRecipes(
        limit: pageSize * apiPage,
        offset: 0,
      );
      
      // Add API recipes
      allRecipes.addAll(apiRecipes);

      // Check if there are more recipes to load
      final hasMore = apiRecipes.length >= pageSize * apiPage;

      return {
        'recipes': allRecipes,
        'hasMore': hasMore,
        'currentPage': page,
      };
    } catch (e) {
      // If API fails, return only local recipes
      final localRecipes = await _databaseService.getAllRecipes();
      return {
        'recipes': localRecipes,
        'hasMore': false,
        'currentPage': page,
      };
    }
  }

  // Load more recipes (for infinite scroll)
  Future<List<Recipe>> loadMoreRecipes(int currentPage) async {
    try {
      final nextPage = currentPage + 1;
      final apiRecipes = await _apiService.fetchRecipes(
        limit: pageSize,
        offset: currentPage * pageSize,
      );
      return apiRecipes;
    } catch (e) {
      return [];
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
