class UpdateProfileRequest {
  final String? displayName;
  final String? phone;
  final String? bio;
  final String? gender; // MALE or FEMALE
  final String? birthday; // yyyy-MM-dd format
  final String? location;
  final String? avatarPath; // Local file path for avatar
  final String? coverPath; // Local file path for cover

  UpdateProfileRequest({
    this.displayName,
    this.phone,
    this.bio,
    this.gender,
    this.birthday,
    this.location,
    this.avatarPath,
    this.coverPath,
  });

  bool get hasData => displayName != null ||
      phone != null ||
      bio != null ||
      gender != null ||
      birthday != null ||
      location != null ||
      avatarPath != null ||
      coverPath != null;
}
