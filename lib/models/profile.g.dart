// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String,
  displayName: json['displayName'] as String,
  bio: json['bio'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  coverUrl: json['coverUrl'] as String?,
  location: json['location'] as String?,
  website: json['website'] as String?,
  joinedAt: json['joinedAt'] as String,
  relationship: Relationship.fromJson(
    json['relationship'] as Map<String, dynamic>,
  ),
  socialStats: SocialStats.fromJson(
    json['socialStats'] as Map<String, dynamic>,
  ),
  educations: (json['educations'] as List<dynamic>)
      .map((e) => Education.fromJson(e as Map<String, dynamic>))
      .toList(),
  workExperiences: (json['workExperiences'] as List<dynamic>)
      .map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
      .toList(),
  interests: (json['interests'] as List<dynamic>)
      .map((e) => Interest.fromJson(e as Map<String, dynamic>))
      .toList(),
  locations: (json['locations'] as List<dynamic>)
      .map((e) => UserLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
  badges: (json['badges'] as List<dynamic>? ?? [])
      .map((e) => Badge.fromJson(e as Map<String, dynamic>))
      .toList(),
  posts: PostsResponse.fromJson(json['posts'] as Map<String, dynamic>),
  private: json['private'] as bool,
  verified: json['verified'] as bool,
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'bio': instance.bio,
  'avatarUrl': instance.avatarUrl,
  'coverUrl': instance.coverUrl,
  'location': instance.location,
  'website': instance.website,
  'joinedAt': instance.joinedAt,
  'relationship': instance.relationship,
  'socialStats': instance.socialStats,
  'educations': instance.educations,
  'workExperiences': instance.workExperiences,
  'interests': instance.interests,
  'locations': instance.locations,
  'badges': instance.badges,
  'posts': instance.posts,
  'private': instance.private,
  'verified': instance.verified,
};

Relationship _$RelationshipFromJson(Map<String, dynamic> json) => Relationship(
  canSendFriendRequest: json['canSendFriendRequest'] as bool,
  friendshipStatus: json['friendshipStatus'] as String?,
  relationshipStatus: json['relationshipStatus'] as String?,
  actionAvailable: json['actionAvailable'] as String?,
  following: json['following'] as bool,
  friend: json['friend'] as bool,
  blocked: json['blocked'] as bool,
  followedBy: json['followedBy'] as bool,
  blockedBy: json['blockedBy'] as bool,
  mutualFollow: json['mutualFollow'] as bool,
);

Map<String, dynamic> _$RelationshipToJson(Relationship instance) =>
    <String, dynamic>{
      'canSendFriendRequest': instance.canSendFriendRequest,
      'friendshipStatus': instance.friendshipStatus,
      'relationshipStatus': instance.relationshipStatus,
      'actionAvailable': instance.actionAvailable,
      'following': instance.following,
      'friend': instance.friend,
      'blocked': instance.blocked,
      'followedBy': instance.followedBy,
      'blockedBy': instance.blockedBy,
      'mutualFollow': instance.mutualFollow,
    };

SocialStats _$SocialStatsFromJson(Map<String, dynamic> json) => SocialStats(
  userId: (json['userId'] as num).toInt(),
  followersCount: (json['followersCount'] as num).toInt(),
  followingCount: (json['followingCount'] as num).toInt(),
  friendsCount: (json['friendsCount'] as num).toInt(),
  postsCount: (json['postsCount'] as num).toInt(),
  likesCount: (json['likesCount'] as num).toInt(),
  commentsCount: (json['commentsCount'] as num).toInt(),
  sharesCount: (json['sharesCount'] as num).toInt(),
);

Map<String, dynamic> _$SocialStatsToJson(SocialStats instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'friendsCount': instance.friendsCount,
      'postsCount': instance.postsCount,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
    };

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
  id: (json['id'] as num).toInt(),
  schoolName: json['schoolName'] as String,
  degree: json['degree'] as String,
  fieldOfStudy: json['fieldOfStudy'] as String,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  isCurrent: json['isCurrent'] as bool,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
  'id': instance.id,
  'schoolName': instance.schoolName,
  'degree': instance.degree,
  'fieldOfStudy': instance.fieldOfStudy,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'isCurrent': instance.isCurrent,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

WorkExperience _$WorkExperienceFromJson(Map<String, dynamic> json) =>
    WorkExperience(
      id: (json['id'] as num).toInt(),
      companyName: json['companyName'] as String,
      position: json['position'] as String,
      location: json['location'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      isCurrent: json['isCurrent'] as bool,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$WorkExperienceToJson(WorkExperience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyName': instance.companyName,
      'position': instance.position,
      'location': instance.location,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'isCurrent': instance.isCurrent,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

Interest _$InterestFromJson(Map<String, dynamic> json) => Interest(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$InterestToJson(Interest instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
  id: (json['id'] as num).toInt(),
  locationName: json['locationName'] as String,
  locationType: json['locationType'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isCurrent: json['isCurrent'] as bool,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationName': instance.locationName,
      'locationType': instance.locationType,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'isCurrent': instance.isCurrent,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

PostsResponse _$PostsResponseFromJson(Map<String, dynamic> json) =>
    PostsResponse(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => ProfilePost.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['currentPage'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );

Map<String, dynamic> _$PostsResponseToJson(PostsResponse instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrevious': instance.hasPrevious,
    };

ProfilePost _$ProfilePostFromJson(Map<String, dynamic> json) => ProfilePost(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String,
  media: (json['media'] as List<dynamic>)
      .map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String,
  likesCount: (json['likesCount'] as num).toInt(),
  commentsCount: (json['commentsCount'] as num).toInt(),
  sharesCount: (json['sharesCount'] as num).toInt(),
  liked: json['liked'] as bool,
  bookmarked: json['bookmarked'] as bool,
);

Map<String, dynamic> _$ProfilePostToJson(ProfilePost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'media': instance.media,
      'createdAt': instance.createdAt,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
      'liked': instance.liked,
      'bookmarked': instance.bookmarked,
    };
