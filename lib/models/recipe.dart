class Recipe {
  final int? id;
  final String title;
  final String image;
  final double rating;
  final String time;
  final String? description;
  final String source; // 'API' or 'LOCAL'

  Recipe({
    this.id,
    required this.title,
    required this.image,
    required this.rating,
    required this.time,
    this.description,
    this.source = 'LOCAL',
  });

  // Convert Recipe to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'rating': rating,
      'time': time,
      'description': description ?? '',
      'source': source,
    };
  }

  // Create Recipe from Map (from database)
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      image: map['image'] as String,
      rating: (map['rating'] as num).toDouble(),
      time: map['time'] as String,
      description: map['description'] as String?,
      source: map['source'] as String? ?? 'LOCAL',
    );
  }

  // Create Recipe from API response (FakeStore API)
  factory Recipe.fromApi(Map<String, dynamic> json) {
    // Map product data to recipe format
    final rating = json['rating'] != null
        ? (json['rating']['rate'] as num).toDouble()
        : 3.0;
    
    // Generate a default time based on product ID or use a default
    final time = '${20 + (json['id'] as int? ?? 0) % 20} min';
    
    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] as String,
      rating: rating,
      time: time,
      description: json['description'] as String?,
      source: 'API',
    );
  }

  // Create a copy of Recipe with updated fields
  Recipe copyWith({
    int? id,
    String? title,
    String? image,
    double? rating,
    String? time,
    String? description,
    String? source,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      time: time ?? this.time,
      description: description ?? this.description,
      source: source ?? this.source,
    );
  }
}

