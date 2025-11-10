import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../utils/url_helper.dart';

class ProfileInfoSection extends StatelessWidget {
  final Profile profile;
  final bool isCurrentUser;
  final VoidCallback? onEditEducation;
  final VoidCallback? onEditWork;
  final VoidCallback? onEditLocation;
  final VoidCallback? onEditInterest;

  const ProfileInfoSection({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.onEditEducation,
    this.onEditWork,
    this.onEditLocation,
    this.onEditInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bio and Basic Info
        if (profile.bio != null || profile.website != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.bio != null)
                  Text(
                    profile.bio!,
                    style: const TextStyle(fontSize: 16),
                  ),
                if (profile.website != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        profile.website!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

        // Stats
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Bài viết',
                profile.socialStats.postsCount.toString(),
              ),
              _buildStatItem(
                'Bạn bè',
                profile.socialStats.friendsCount.toString(),
              ),
              _buildStatItem(
                'Người theo dõi',
                profile.socialStats.followersCount.toString(),
              ),
              _buildStatItem(
                'Đang theo dõi',
                profile.socialStats.followingCount.toString(),
              ),
            ],
          ),
        ),

        // Work Experience
        if (profile.workExperiences.isNotEmpty || isCurrentUser)
          _buildSection(
            'Công việc',
            profile.workExperiences.map((work) {
              return ListTile(
                leading: work.imageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          UrlHelper.fixImageUrl(work.imageUrl!),
                        ),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.work),
                      ),
                title: Text(work.position),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(work.companyName),
                    Text(
                      work.isCurrent ? 'Hiện tại' : (work.startDate ?? 'Chưa rõ'),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            }).toList(),
            onAdd: isCurrentUser ? onEditWork : null,
          ),

        // Education
        if (profile.educations.isNotEmpty || isCurrentUser)
          _buildSection(
            'Học vấn',
            profile.educations.map((edu) {
              return ListTile(
                leading: edu.imageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          UrlHelper.fixImageUrl(edu.imageUrl!),
                        ),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.school),
                      ),
                title: Text(edu.schoolName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${edu.degree} - ${edu.fieldOfStudy}'),
                    Text(
                      edu.isCurrent ? 'Hiện tại' : (edu.startDate ?? 'Chưa rõ'),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            }).toList(),
            onAdd: isCurrentUser ? onEditEducation : null,
          ),

        // Locations
        if (profile.locations.isNotEmpty || isCurrentUser)
          _buildSection(
            'Địa điểm',
            profile.locations.map((loc) {
              IconData icon;
              String type;
              switch (loc.locationType) {
                case 'hometown':
                  icon = Icons.home;
                  type = 'Quê quán';
                  break;
                case 'education':
                  icon = Icons.school;
                  type = 'Nơi học tập';
                  break;
                default:
                  icon = Icons.location_on;
                  type = 'Địa điểm';
              }
              return ListTile(
                leading: CircleAvatar(child: Icon(icon)),
                title: Text(loc.locationName),
                subtitle: Text(type),
              );
            }).toList(),
            onAdd: isCurrentUser ? onEditLocation : null,
          ),

        // Interests
        if (profile.interests.isNotEmpty || isCurrentUser)
          _buildSection(
            'Sở thích',
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.interests.map((interest) {
                  return Chip(
                    avatar: const CircleAvatar(
                      child: Icon(Icons.favorite, size: 16),
                    ),
                    label: Text(interest.name),
                  );
                }).toList(),
              ),
            ],
            onAdd: isCurrentUser ? onEditInterest : null,
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children, {VoidCallback? onAdd}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onAdd != null)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onAdd,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (children.isEmpty)
            Center(
              child: Text(
                'Chưa có thông tin',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}
