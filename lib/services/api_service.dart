import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const int itemsPerPage = 10; // Number of items per page

  // Fetch recipes with pagination support
  Future<List<Recipe>> fetchRecipes({
    int limit = 10,
    int offset = 0,
    String? category,
  }) async {
    try {
      // Build URL with optional category filter
      String url = '$baseUrl/products';
      if (category != null && category.isNotEmpty && category != 'all') {
        url = '$baseUrl/products/category/$category';
      } else {
        url = '$baseUrl/products?limit=$limit';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final recipes = data.map((json) => Recipe.fromApi(json)).toList();
        
        // Apply limit and offset for pagination (client-side)
        if (category == null || category.isEmpty || category == 'all') {
          if (limit > 0 && recipes.length > limit) {
            final limitedRecipes = recipes.take(limit).toList();
            if (offset > 0 && offset < limitedRecipes.length) {
              return limitedRecipes.skip(offset).toList();
            }
            return limitedRecipes;
          }
        }
        
        if (offset > 0 && offset < recipes.length) {
          return recipes.skip(offset).toList();
        }
        return recipes;
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  // Fetch all categories
  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Fetch all recipes (for initial load or refresh)
  Future<List<Recipe>> fetchAllRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromApi(json)).toList();
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }
}
