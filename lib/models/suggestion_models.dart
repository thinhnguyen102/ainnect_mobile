class SchoolSuggestion {
  final String schoolName;
  final int count;
  final String? imageUrl;

  SchoolSuggestion({
    required this.schoolName,
    required this.count,
    this.imageUrl,
  });

  factory SchoolSuggestion.fromJson(Map<String, dynamic> json) {
    return SchoolSuggestion(
      schoolName: json['schoolName'] as String,
      count: (json['count'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolName': schoolName,
      'count': count,
      'imageUrl': imageUrl,
    };
  }
}

class CompanySuggestion {
  final String companyName;
  final int count;
  final String? imageUrl;

  CompanySuggestion({
    required this.companyName,
    required this.count,
    this.imageUrl,
  });

  factory CompanySuggestion.fromJson(Map<String, dynamic> json) {
    return CompanySuggestion(
      companyName: json['companyName'] as String,
      count: (json['count'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'count': count,
      'imageUrl': imageUrl,
    };
  }
}

class InterestSuggestion {
  final String name;
  final int count;
  final String? imageUrl;

  InterestSuggestion({
    required this.name,
    required this.count,
    this.imageUrl,
  });

  factory InterestSuggestion.fromJson(Map<String, dynamic> json) {
    return InterestSuggestion(
      name: json['name'] as String,
      count: (json['count'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'imageUrl': imageUrl,
    };
  }
}

class LocationSuggestion {
  final String locationName;
  final int count;
  final String? imageUrl;

  LocationSuggestion({
    required this.locationName,
    required this.count,
    this.imageUrl,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      locationName: json['locationName'] as String,
      count: (json['count'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationName': locationName,
      'count': count,
      'imageUrl': imageUrl,
    };
  }
}

class CategorySuggestion {
  final String category;

  CategorySuggestion({
    required this.category,
  });

  factory CategorySuggestion.fromJson(Map<String, dynamic> json) {
    return CategorySuggestion(
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
    };
  }
}

class SuggestionResponse<T> {
  final List<T> suggestions;
  final int total;

  SuggestionResponse({
    required this.suggestions,
    required this.total,
  });

  factory SuggestionResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return SuggestionResponse<T>(
      suggestions: (json['suggestions'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}
