import 'dart:convert';

class Recipe {
  final int? id; 
  final String title;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final int cooktime;
  final String? image;
  final bool favorite;
  final String date;

  Recipe({
    this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.cooktime,
    this.image,
    this.favorite = false,
    required this.date,
  });

  static const categories = [
    'breakfast',
    'lunch',
    'dinner',
    'dessert',
    'snack',
  ];
  ///sqfile needs map 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'ingredients': jsonEncode(ingredients),
      'steps': jsonEncode(steps),
      'cooktime': cooktime,
      'image': image,
      'favorite': favorite ? 1 : 0,
      'date': date,
    };
  }
  //convert to object
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      ingredients: List<String>.from(jsonDecode(map['ingredients'] as String)),
      steps: List<String>.from(jsonDecode(map['steps'] as String)),
      cooktime: map['cooktime'] as int,
      image: map['image'] as String?,
      favorite: (map['favorite'] as int) == 1,
      date: map['date'] as String,

    );
  }
  //needed to change/edit recipe 
  Recipe copyWith({
    int? id,
    String? title,
    String? category,
    List<String>? ingredients,
    List<String>? steps,
    int? cooktime,
    String? image,
    bool? favorite,
    String? date,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      cooktime: cooktime ?? this.cooktime,
      image: image ?? this.image,
      favorite: favorite ?? this.favorite,
      date: date ?? this.date,
    );
  }
}

