class LocationRequest {
  final String? locationName;
  final String? locationType;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool? isCurrent;
  final String? imageUrl; // Public URL

  LocationRequest({
    this.locationName,
    this.locationType,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.isCurrent,
    this.imageUrl,
  });

  bool get hasData =>
      locationName != null ||
      locationType != null ||
      address != null ||
      latitude != null ||
      longitude != null ||
      description != null ||
      isCurrent != null ||
      imageUrl != null;
}
