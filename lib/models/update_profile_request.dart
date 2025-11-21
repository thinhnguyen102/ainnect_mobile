class UpdateProfileRequest {
  final String? displayName;
  final String? phone;
  final String? bio;
  final String? gender; // MALE or FEMALE
  final String? birthday; // yyyy-MM-dd format
  final String? location;
  final String? avatarUrl; // Public URL for avatar
  final String? coverUrl; // Public URL for cover

  UpdateProfileRequest({
    this.displayName,
    this.phone,
    this.bio,
    this.gender,
    this.birthday,
    this.location,
    this.avatarUrl,
    this.coverUrl,
  });

  bool get hasData => displayName != null ||
      phone != null ||
      bio != null ||
      gender != null ||
      birthday != null ||
      location != null ||
      avatarUrl != null ||
      coverUrl != null;
}
