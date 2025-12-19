import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        image TEXT NOT NULL,
        rating REAL NOT NULL DEFAULT 3.0,
        time TEXT NOT NULL,
        description TEXT,
        source TEXT NOT NULL DEFAULT 'LOCAL'
      )
    ''');
  }

  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    return await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get recipes with pagination
  Future<List<Recipe>> getRecipes({int limit = 10, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      limit: limit,
      offset: offset,
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recipes');

    return List.generate(maps.length, (i) {
      return Recipe.fromMap(maps[i]);
    });
  }

  Future<Recipe?> getRecipe(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Recipe.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getLocalRecipeCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM recipes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
