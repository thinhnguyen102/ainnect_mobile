class LocationRequest {
  final String? locationName;
  final String? locationType;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool? isCurrent;
  final String? imagePath; // Local file path

  LocationRequest({
    this.locationName,
    this.locationType,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.isCurrent,
    this.imagePath,
  });

  bool get hasData =>
      locationName != null ||
      locationType != null ||
      address != null ||
      latitude != null ||
      longitude != null ||
      description != null ||
      isCurrent != null ||
      imagePath != null;
}
