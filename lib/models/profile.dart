import 'package:json_annotation/json_annotation.dart';
import 'post.dart';
import 'badge.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  final int userId;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final String? location;
  final String? website;
  final String joinedAt;
  final Relationship relationship;
  final SocialStats socialStats;
  final List<Education> educations;
  final List<WorkExperience> workExperiences;
  final List<Interest> interests;
  final List<UserLocation> locations;
  final List<Badge> badges;
  final PostsResponse posts;
  final bool private;
  final bool verified;

  const Profile({
    required this.userId,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.location,
    this.website,
    required this.joinedAt,
    required this.relationship,
    required this.socialStats,
    required this.educations,
    required this.workExperiences,
    required this.interests,
    required this.locations,
    required this.badges,
    required this.posts,
    required this.private,
    required this.verified,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    PostsResponse? posts,
    Relationship? relationship,
  }) {
    return Profile(
      userId: userId,
      username: username,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      location: location,
      website: website,
      joinedAt: joinedAt,
      relationship: relationship ?? this.relationship,
      socialStats: socialStats,
      educations: educations,
      workExperiences: workExperiences,
      interests: interests,
      locations: locations,
      badges: badges,
      posts: posts ?? this.posts,
      private: private,
      verified: verified,
    );
  }
}

@JsonSerializable()
class Relationship {
  final bool canSendFriendRequest;
  final String? friendshipStatus;
  final String? relationshipStatus;
  final String? actionAvailable;
  final bool following;
  final bool friend;
  final bool blocked;
  final bool followedBy;
  final bool blockedBy;
  final bool mutualFollow;

  const Relationship({
    required this.canSendFriendRequest,
    this.friendshipStatus,
    this.relationshipStatus,
    this.actionAvailable,
    required this.following,
    required this.friend,
    required this.blocked,
    required this.followedBy,
    required this.blockedBy,
    required this.mutualFollow,
  });

  factory Relationship.fromJson(Map<String, dynamic> json) => _$RelationshipFromJson(json);
  Map<String, dynamic> toJson() => _$RelationshipToJson(this);
}

@JsonSerializable()
class SocialStats {
  final int userId;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final int postsCount;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;

  const SocialStats({
    required this.userId,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.postsCount,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
  });

  factory SocialStats.fromJson(Map<String, dynamic> json) => _$SocialStatsFromJson(json);
  Map<String, dynamic> toJson() => _$SocialStatsToJson(this);
}

@JsonSerializable()
class Education {
  final int id;
  final String schoolName;
  final String degree;
  final String fieldOfStudy;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  const Education({
    required this.id,
    required this.schoolName,
    required this.degree,
    required this.fieldOfStudy,
    this.startDate,
    this.endDate,
    required this.isCurrent,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Education.fromJson(Map<String, dynamic> json) => _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}

@JsonSerializable()
class WorkExperience {
  final int id;
  final String companyName;
  final String position;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  const WorkExperience({
    required this.id,
    required this.companyName,
    required this.position,
    this.location,
    this.startDate,
    this.endDate,
    required this.isCurrent,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) => _$WorkExperienceFromJson(json);
  Map<String, dynamic> toJson() => _$WorkExperienceToJson(this);
}

@JsonSerializable()
class Interest {
  final int id;
  final String name;
  final String category;
  final String? description;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  const Interest({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Interest.fromJson(Map<String, dynamic> json) => _$InterestFromJson(json);
  Map<String, dynamic> toJson() => _$InterestToJson(this);
}

@JsonSerializable()
class UserLocation {
  final int id;
  final String locationName;
  final String locationType;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? imageUrl;
  final bool isCurrent;
  final String createdAt;
  final String updatedAt;

  const UserLocation({
    required this.id,
    required this.locationName,
    required this.locationType,
    required this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.imageUrl,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) => _$UserLocationFromJson(json);
  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable()
class PostsResponse {
  final List<ProfilePost> posts;
  final int currentPage;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PostsResponse({
    required this.posts,
    required this.currentPage,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) => _$PostsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PostsResponseToJson(this);
}

@JsonSerializable()
class ProfilePost {
  final int id;
  final String content;
  final List<PostMedia> media;
  final String createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool liked;
  final bool bookmarked;

  const ProfilePost({
    required this.id,
    required this.content,
    required this.media,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.liked,
    required this.bookmarked,
  });

  factory ProfilePost.fromJson(Map<String, dynamic> json) => _$ProfilePostFromJson(json);
  Map<String, dynamic> toJson() => _$ProfilePostToJson(this);
}