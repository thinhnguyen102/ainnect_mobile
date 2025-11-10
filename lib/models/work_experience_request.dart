class WorkExperienceRequest {
  final String? startDate; // yyyy-MM-dd
  final String? endDate; // yyyy-MM-dd
  final bool? isCurrent;
  final String? description;
  final String? imagePath; // Local file path

  WorkExperienceRequest({
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.description,
    this.imagePath,
  });

  bool get hasData =>
      startDate != null ||
      endDate != null ||
      isCurrent != null ||
      description != null ||
      imagePath != null;
}
