import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const int itemsPerPage = 10; // Number of items per page

  // Fetch recipes with pagination support
  Future<List<Recipe>> fetchRecipes({int limit = 10, int offset = 0}) async {
    try {
      // FakeStore API supports limit parameter
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final recipes = data.map((json) => Recipe.fromApi(json)).toList();
        
        // Apply offset for pagination (client-side since API doesn't support offset)
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
