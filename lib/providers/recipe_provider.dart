import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _repository = RecipeRepository();
  
  List<Recipe> _recipes = [];
  List<String> _categories = [];
  String _selectedCategory = 'all';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  List<Recipe> get recipes => _recipes;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  RecipeProvider() {
    loadCategories();
    loadRecipes();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      // If categories fail to load, use default categories
      _categories = ['electronics', "men's clothing", "women's clothing", 'jewelery'];
      notifyListeners();
    }
  }

  Future<void> loadRecipes({bool refresh = false, String? category}) async {
    if (refresh) {
      _currentPage = 1;
      _recipes.clear();
      _hasMore = true;
      // Reset to "all" on refresh
      if (category == null) {
        _selectedCategory = 'all';
      } else {
        _selectedCategory = category;
      }
    } else if (category != null) {
      _selectedCategory = category;
      _currentPage = 1;
      _recipes.clear();
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getRecipes(
        page: _currentPage,
        loadMore: false,
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      
      if (refresh || category != null) {
        _recipes = result['recipes'] as List<Recipe>;
      } else {
        _recipes.addAll(result['recipes'] as List<Recipe>);
      }
      
      _hasMore = result['hasMore'] as bool;
      _currentPage = result['currentPage'] as int;
      _error = null;
    } catch (e) {
      _error = 'Failed to load recipes: $e';
      if (_recipes.isEmpty) {
        _recipes = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory != category) {
      loadRecipes(category: category);
    }
  }

  Future<void> loadMoreRecipes() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final moreRecipes = await _repository.loadMoreRecipes(
        _currentPage,
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      
      if (moreRecipes.isNotEmpty) {
        _recipes.addAll(moreRecipes);
        _currentPage = nextPage;
        _hasMore = moreRecipes.length >= RecipeRepository.pageSize;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _error = 'Failed to load more recipes: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _repository.addRecipe(recipe);
      // Reload to get updated list with new recipe
      await loadRecipes(refresh: true);
    } catch (e) {
      _error = 'Failed to add recipe: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _repository.updateRecipe(recipe);
      await loadRecipes(refresh: true);
    } catch (e) {
      _error = 'Failed to update recipe: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      await _repository.deleteRecipe(id);
      // Remove from local list
      _recipes.removeWhere((recipe) => recipe.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete recipe: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshRecipes() async {
    // Reset to "all" category on refresh
    await loadRecipes(refresh: true);
  }
}
