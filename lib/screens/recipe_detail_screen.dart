import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'add_edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RecipeProvider>().deleteRecipe(recipe.id!);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          //IconButton(
            //icon: Icon(
              //recipe.favorite ? Icons.favorite : Icons.favorite_border,
              //color: recipe.favorite ? Colors.blueAccent : null,
            //),
            //onPressed: () => context.read<RecipeProvider>().toggleFavorite(recipe),
          //),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditRecipeScreen(recipe: recipe),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (recipe.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(recipe.image!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(label: Text(recipe.category)),
              const SizedBox(width: 12),
              Icon(Icons.timer_outlined, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${recipe.cooktime} min'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...recipe.ingredients.map(
            (ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 6),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingredient)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Steps', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...recipe.steps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}