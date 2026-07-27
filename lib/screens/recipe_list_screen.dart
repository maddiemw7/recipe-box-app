import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'add_edit_recipe_screen.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white54,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Text(
                      'Recipe Box',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildBody(context, provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditRecipeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RecipeProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(provider.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: provider.loadRecipes,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                  onChanged: provider.setSearchQuery,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  provider.showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                  color: provider.showFavoritesOnly ? Colors.blueAccent : Colors.grey,
                ),
                onPressed: provider.toggleShowFavoritesOnly,
                tooltip: 'Show favorites only',
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: ['All', ...Recipe.categories].map((category) {
              final isSelected = provider.selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: Colors.blue.shade200,
                  onSelected: (_) => provider.setCategory(category),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: provider.filteredRecipes.isEmpty
              ? _buildEmptyState(provider)
              : ListView.builder(
                  itemCount: provider.filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = provider.filteredRecipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                      onFavoriteToggle: () => provider.toggleFavorite(recipe),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(RecipeProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty ||
        provider.selectedCategory != 'All' ||
        provider.showFavoritesOnly;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.menu_book_outlined,
            size: 56,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            hasFilters ? 'No recipes match your filters' : 'No recipes yet',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (!hasFilters) ...[
            const SizedBox(height: 4),
            const Text(
              'Tap + to add your first recipe',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}