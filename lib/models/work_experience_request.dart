class WorkExperienceRequest {
  final String? companyName;
  final String? position;
  final String? location;
  final String? startDate; // yyyy-MM-dd
  final String? endDate; // yyyy-MM-dd
  final bool? isCurrent;
  final String? description;
  final String? imageUrl; // Public URL

  WorkExperienceRequest({
    this.companyName,
    this.position,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.description,
    this.imageUrl,
  });

  bool get hasData =>
      companyName != null ||
      position != null ||
      location != null ||
      startDate != null ||
      endDate != null ||
      isCurrent != null ||
      description != null ||
      imageUrl != null;
}
