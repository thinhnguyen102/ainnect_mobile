class EducationRequest {
  final String? schoolName;
  final String? degree;
  final String? fieldOfStudy;
  final String? startDate; // yyyy-MM-dd
  final String? endDate; // yyyy-MM-dd
  final bool? isCurrent;
  final String? description;
  final String? imageUrl; // Public URL

  EducationRequest({
    this.schoolName,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.description,
    this.imageUrl,
  });

  bool get hasData =>
      schoolName != null ||
      degree != null ||
      fieldOfStudy != null ||
      startDate != null ||
      endDate != null ||
      isCurrent != null ||
      description != null ||
      imageUrl != null;
}
