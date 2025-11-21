class InterestRequest {
  final String? name;
  final String? category;
  final String? description;
  final String? imageUrl; // Public URL

  InterestRequest({
    this.name,
    this.category,
    this.description,
    this.imageUrl,
  });

  bool get hasData =>
      name != null ||
      category != null ||
      description != null ||
      imageUrl != null;
}
