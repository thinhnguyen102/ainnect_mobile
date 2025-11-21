import 'package:flutter/material.dart';
import '../utils/url_helper.dart';

class UserAvatar extends StatefulWidget {
  final String? avatarUrl;
  final String displayName;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.displayName,
    this.radius = 20,
    this.onTap,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  late Future<Map<String, String>> _headersFuture;

  @override
  void initState() {
    super.initState();
    _headersFuture = UrlHelper.getHeaders();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: FutureBuilder<Map<String, String>>(
        future: _headersFuture,
        builder: (context, snapshot) {
          final headers = snapshot.data;
          final fixedUrl = UrlHelper.fixImageUrl(widget.avatarUrl);
          ImageProvider? provider;
          if (fixedUrl != null && headers != null) {
            provider = NetworkImage(fixedUrl, headers: headers);
          }

          return CircleAvatar(
            radius: widget.radius,
            backgroundColor: const Color(0xFF1E88E5),
            backgroundImage: provider,
            child: provider == null
                ? Text(
                    widget.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
