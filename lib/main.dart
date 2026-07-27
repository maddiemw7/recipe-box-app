import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/recipe_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeProvider()..loadRecipes(),
      child: MaterialApp(
        title: 'Recipe Box App',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const RecipeListScreen(),
      ),
    );
  }
}