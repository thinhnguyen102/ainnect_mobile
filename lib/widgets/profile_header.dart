import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../utils/url_helper.dart';

class ProfileHeader extends StatelessWidget {
  final Profile profile;
  final bool isCurrentUser;
  final VoidCallback? onEditCover;
  final VoidCallback? onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.onEditCover,
    this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (profile.coverUrl != null)
                Image.network(
                  UrlHelper.fixImageUrl(profile.coverUrl!),
                  fit: BoxFit.cover,
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              if (isCurrentUser)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: onEditCover,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Avatar
        Positioned(
          left: 16,
          bottom: -60,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(UrlHelper.fixImageUrl(profile.avatarUrl!))
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.displayName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              if (isCurrentUser)
                Positioned(
                  right: -4,
                  bottom: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: onEditAvatar,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Verified Badge
        if (profile.verified)
          Positioned(
            left: 140,
            bottom: -50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Đã xác minh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
