class Dish {
  final String id;
  final String name;
  final String cuisine;
  final String country;
  final String flag;
  final String region;
  final String emoji;
  final String description;
  final List<String> ingredients;
  final List<String> ingredientsFull;
  final List<String> tags;
  final List<String> mealType;
  final List<String> dietary;
  final String spice;
  final String prepTime;
  final String difficulty;
  final String servings;
  final List<String> instructions;
  final Nutrition? nutrition;
  final int? matchCount;

  const Dish({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.country,
    required this.flag,
    required this.region,
    required this.emoji,
    required this.description,
    required this.ingredients,
    required this.ingredientsFull,
    required this.tags,
    required this.mealType,
    required this.dietary,
    required this.spice,
    required this.prepTime,
    required this.difficulty,
    required this.servings,
    required this.instructions,
    this.nutrition,
    this.matchCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cuisine': cuisine,
        'country': country,
        'flag': flag,
        'region': region,
        'emoji': emoji,
        'description': description,
        'ingredients': ingredients,
        'ingredientsFull': ingredientsFull,
        'tags': tags,
        'mealType': mealType,
        'dietary': dietary,
        'spice': spice,
        'prepTime': prepTime,
        'difficulty': difficulty,
        'servings': servings,
        'instructions': instructions,
        if (nutrition != null) 'nutrition': nutrition!.toJson(),
        if (matchCount != null) 'matchCount': matchCount,
      };

  String get category {
    if (mealType.contains('breakfast')) return 'Breakfast';
    if (mealType.contains('dessert')) return 'Dessert';
    if (mealType.contains('snack')) return 'Snack';
    if (mealType.contains('lunch') || mealType.contains('dinner')) return 'Lunch/Dinner';
    return mealType.isNotEmpty ? mealType.first : '';
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cuisine: json['cuisine'] ?? '',
      country: json['country'] ?? '',
      flag: json['flag'] ?? '',
      region: json['region'] ?? '',
      emoji: json['emoji'] ?? '',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      ingredientsFull: List<String>.from(json['ingredientsFull'] ?? json['ingredients'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      mealType: List<String>.from(json['mealType'] ?? []),
      dietary: List<String>.from(json['dietary'] ?? []),
      spice: json['spice'] ?? 'mild',
      prepTime: json['prepTime'] ?? '',
      difficulty: json['difficulty'] ?? '',
      servings: json['servings'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
      nutrition: json['nutrition'] != null ? Nutrition.fromJson(json['nutrition']) : null,
      matchCount: json['matchCount'],
    );
  }
}

class Nutrition {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;

  const Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
      };

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: (json['calories'] ?? 0).toInt(),
      protein: (json['protein'] ?? 0).toInt(),
      carbs: (json['carbs'] ?? 0).toInt(),
      fat: (json['fat'] ?? 0).toInt(),
      fiber: (json['fiber'] ?? 0).toInt(),
    );
  }
}
