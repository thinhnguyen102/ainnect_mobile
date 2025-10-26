import 'package:flutter/material.dart';
import '../models/post.dart';
import 'media_preview.dart';

class MediaGallery extends StatelessWidget {
  final List<PostMedia> media;

  const MediaGallery({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    // Filter out media items with null URLs
    final validMedia = media.where((item) => item.mediaUrl != null).toList();
    
    if (validMedia.isEmpty) return const SizedBox.shrink();

    if (validMedia.length == 1) {
      return _buildSingleImage(validMedia[0]);
    } else if (validMedia.length == 2) {
      return _buildTwoImages(validMedia);
    } else if (validMedia.length == 3) {
      return _buildThreeImages(validMedia);
    } else {
      return _buildFourOrMoreImages(validMedia);
    }
  }

  Widget _buildSingleImage(PostMedia mediaItem) {
    // Skip media items with null URLs
    if (mediaItem.mediaUrl == null) {
      return const SizedBox.shrink();
    }
    
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: MediaPreview(
          mediaUrl: mediaItem.mediaUrl!,
          mediaType: mediaItem.mediaType ?? 'image',
        ),
      ),
    );
  }

  Widget _buildTwoImages(List<PostMedia> validMedia) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(child: _buildSingleImage(validMedia[0])),
          const SizedBox(width: 2),
          Expanded(child: _buildSingleImage(validMedia[1])),
        ],
      ),
    );
  }

  Widget _buildThreeImages(List<PostMedia> validMedia) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildSingleImage(validMedia[0]),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildSingleImage(validMedia[1])),
                const SizedBox(height: 2),
                Expanded(child: _buildSingleImage(validMedia[2])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourOrMoreImages(List<PostMedia> validMedia) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildSingleImage(validMedia[0])),
                const SizedBox(width: 2),
                Expanded(child: _buildSingleImage(validMedia[1])),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildSingleImage(validMedia[2]),
                      if (validMedia.length > 4)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${validMedia.length - 4}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(child: _buildSingleImage(validMedia[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}