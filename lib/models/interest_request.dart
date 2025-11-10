class InterestRequest {
  final String? name;
  final String? category;
  final String? description;
  final String? imagePath; // Local file path

  InterestRequest({
    this.name,
    this.category,
    this.description,
    this.imagePath,
  });

  bool get hasData =>
      name != null ||
      category != null ||
      description != null ||
      imagePath != null;
}
