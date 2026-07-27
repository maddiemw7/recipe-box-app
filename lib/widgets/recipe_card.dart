import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.blue.shade100, width: 2),
  ), //round image edges
      child: InkWell( //makes non button widget interactive 
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              //shows photo or placeholder 
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: recipe.image != null
                    ? Image.file(
                        File(recipe.image!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: Colors.lightBlue[300],
                        child: const Icon(Icons.restaurant, color: Colors.lightBlue),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(recipe.category, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text('${recipe.cooktime} min',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              //favorite button
              IconButton(
                icon: Icon(
                  recipe.favorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.favorite ? Colors.blueAccent : Colors.grey,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}