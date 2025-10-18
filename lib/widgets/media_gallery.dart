import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/url_helper.dart';
import 'media_preview.dart';

class MediaGallery extends StatelessWidget {
  final List<PostMedia> media;

  const MediaGallery({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();

    if (media.length == 1) {
      return _buildSingleImage(media[0]);
    } else if (media.length == 2) {
      return _buildTwoImages();
    } else if (media.length == 3) {
      return _buildThreeImages();
    } else {
      return _buildFourOrMoreImages();
    }
  }

  Widget _buildSingleImage(PostMedia mediaItem) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: MediaPreview(
          mediaUrl: mediaItem.mediaUrl,
          mediaType: mediaItem.mediaType,
        ),
      ),
    );
  }

  Widget _buildTwoImages() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(child: _buildSingleImage(media[0])),
          const SizedBox(width: 2),
          Expanded(child: _buildSingleImage(media[1])),
        ],
      ),
    );
  }

  Widget _buildThreeImages() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildSingleImage(media[0]),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildSingleImage(media[1])),
                const SizedBox(height: 2),
                Expanded(child: _buildSingleImage(media[2])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourOrMoreImages() {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildSingleImage(media[0])),
                const SizedBox(width: 2),
                Expanded(child: _buildSingleImage(media[1])),
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
                      _buildSingleImage(media[2]),
                      if (media.length > 4)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${media.length - 4}',
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
                Expanded(child: _buildSingleImage(media[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}