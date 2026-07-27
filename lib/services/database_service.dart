import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';

//used across app - one instance 
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db; //catch if database is open 

  //get database connection - open if not already open
  Future<Database> get database async {
    if (_db != null) return _db!; //reuse if open
    _db = await _initDb(); //otherwise open
    return _db!;
  }

  //open db file 
  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'recipe_box.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE recipes(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            ingredients TEXT NOT NULL,
            steps TEXT NOT NULL,
            cooktime INTEGER NOT NULL,
            image TEXT,
            favorite INTEGER NOT NULL DEFAULT 0,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }
  //create
  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    return db.insert('recipes', recipe.toMap());
  }
  //read
  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    return db.update('recipes', recipe.toMap(), where: 'id = ?', whereArgs: [recipe.id]);
  }
  ///update
  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
  //delete 
  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final maps = await db.query('recipes', orderBy: 'date DESC');
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }
}