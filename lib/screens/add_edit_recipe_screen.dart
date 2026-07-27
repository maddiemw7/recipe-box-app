import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _cookTimeController;
  late String _selectedCategory;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;
  String? _imagePath;
  bool _isSaving = false;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _titleController = TextEditingController(text: recipe?.title ?? '');
    _cookTimeController = TextEditingController(
      text: recipe != null ? recipe.cooktime.toString() : '',
    );
    _selectedCategory = recipe?.category ?? Recipe.categories.first;
    _imagePath = recipe?.image;
    _ingredientControllers = (recipe?.ingredients ?? [''])
        .map((i) => TextEditingController(text: i))
        .toList();
    _stepControllers = (recipe?.steps ?? [''])
        .map((s) => TextEditingController(text: s))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cookTimeController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _addIngredientField() {
    setState(() => _ingredientControllers.add(TextEditingController()));
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addStepField() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStepField(int index) {
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    final steps = _stepControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (ingredients.isEmpty || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient and one step')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<RecipeProvider>();
    final recipe = Recipe(
      id: widget.recipe?.id,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      ingredients: ingredients,
      steps: steps,
      cooktime: int.tryParse(_cookTimeController.text.trim()) ?? 0,
      image: _imagePath,
      favorite: widget.recipe?.favorite ?? false,
      date: widget.recipe?.date ?? DateTime.now().toIso8601String(),
    );

    if (_isEditing) {
      await provider.updateRecipe(recipe);
    } else {
      await provider.addRecipe(recipe);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _imagePath != null
                    ? Image.file(
                        File(_imagePath!),
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: Recipe.categories
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cookTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cook Time (minutes)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Cook time is required';
                if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addIngredientField,
                ),
              ],
            ),
            ..._ingredientControllers.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          hintText: 'Ingredient ${entry.key + 1}',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_ingredientControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeIngredientField(entry.key),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Steps', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addStepField,
                ),
              ],
            ),
            ..._stepControllers.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Step ${entry.key + 1}',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_stepControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeStepField(entry.key),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}