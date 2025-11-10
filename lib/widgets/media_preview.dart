import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/url_helper.dart';
import 'simple_video_preview.dart';

class MediaPreview extends StatefulWidget {
  final String mediaUrl;
  final String mediaType;
  final VoidCallback? onRemove;
  final bool autoPlay;
  final bool showControls;
  final String? thumbnailUrl;

  const MediaPreview({
    super.key,
    required this.mediaUrl,
    required this.mediaType,
    this.onRemove,
    this.autoPlay = false,
    this.showControls = true,
    this.thumbnailUrl,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late Future<Map<String, String>> _headersFuture;
  bool _isLocalFile = false;

  @override
  void initState() {
    super.initState();
    // Check if it's a local file path
    _isLocalFile = !widget.mediaUrl.startsWith('http');
    if (!_isLocalFile) {
      _headersFuture = UrlHelper.getHeaders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _headersFuture,
      builder: (context, snapshot) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMediaWidget(snapshot),
              ),
            ),
            if (widget.onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMediaWidget(AsyncSnapshot<Map<String, String>> snapshot) {
    if (widget.mediaType.toLowerCase() == 'video') {
      // Video preview - use SimpleVideoPreview for both local and network videos
      return SimpleVideoPreview(
        videoUrl: widget.mediaUrl,
        thumbnailUrl: widget.thumbnailUrl,
        isLocalFile: _isLocalFile,
      );
    } else {
      // Image
      if (_isLocalFile) {
        // Local image file
        final file = File(widget.mediaUrl);
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Không thể tải ảnh',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        // Network image
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1E88E5),
            ),
          );
        }

        return Image.network(
          UrlHelper.fixImageUrl(widget.mediaUrl),
          headers: snapshot.data,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF1E88E5),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Không thể tải ảnh',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }
}
