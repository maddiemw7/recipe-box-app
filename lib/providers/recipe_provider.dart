import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';

//change notifier to make provider compatible
class RecipeProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Recipe> _recipes = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showFavoritesOnly = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<Recipe> get recipes => _recipes;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //fresh every ask - filters recipe list down to search text + category
  List<Recipe> get filteredRecipes {
    return _recipes.where((r) {
      final matchesCategory = _selectedCategory == 'All' || r.category == _selectedCategory;
      final matchesSearch = r.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorite = !_showFavoritesOnly || r.favorite;
      return matchesCategory && matchesSearch && matchesFavorite;
    }).toList();
  }

  void toggleShowFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  //fetch recipes from databse
  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _recipes = await _dbService.getAllRecipes();
      _errorMessage = null;
    } catch (e, stack) {
      print('LOAD RECIPES ERROR: $e');
      print(stack);
      _errorMessage = 'Failed to load recipes.';
    }
    _isLoading = false;
    notifyListeners();
  }

  //does the matching database operation
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _dbService.insertRecipe(recipe);
      await loadRecipes();
    } catch (e, stack) {
      print('ADD RECIPE ERROR: $e');
      print(stack);
      _errorMessage = 'Failed to save recipe.';
      notifyListeners();
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _dbService.updateRecipe(recipe);
      await loadRecipes();
    } catch (e, stack) {
      print('UPDATE RECIPE ERROR: $e');
      print(stack);
      _errorMessage = 'Failed to update recipe.';
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      await _dbService.deleteRecipe(id);
      await loadRecipes();
    } catch (e) {
      _errorMessage = 'Failed to delete recipe.';
      notifyListeners();
    }
  }

  //uses copywith to change favorite section of recipe
  Future<void> toggleFavorite(Recipe recipe) async {
    final updated = recipe.copyWith(favorite: !recipe.favorite);
    await updateRecipe(updated); //call databse operation
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
