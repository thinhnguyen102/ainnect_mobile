import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../utils/url_helper.dart';


Widget _buildDefaultIcon() {
  return const Center(
    child: Icon(
      Icons.video_library,
      color: Colors.white54,
      size: 80,
    ),
  );
}

/// Simple video placeholder that shows a preview
class SimpleVideoPreview extends StatelessWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool isLocalFile;

  const SimpleVideoPreview({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.isLocalFile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show video modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => VideoPlayerModal(
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            isLocalFile: isLocalFile,
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200, // Set a finite height for preview
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ],
                ),
              ),
              child: thumbnailUrl != null
                  ? FutureBuilder<Map<String, String>>(
                      future: UrlHelper.getHeaders(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                        final resolvedUrl = UrlHelper.fixImageUrl(thumbnailUrl!);
                        if (resolvedUrl == null) {
                          return _buildDefaultIcon();
                        }
                        return Image.network(
                          resolvedUrl,
                          headers: snapshot.data,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultIcon();
                          },
                        );
                      },
                    )
                  : _buildDefaultIcon(),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Play button
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
            // Video badge
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Video player modal with full player controls
class VideoPlayerModal extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool isLocalFile;

  const VideoPlayerModal({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.isLocalFile = false,
  }) : super(key: key);

  @override
  State<VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<VideoPlayerModal> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Create video controller - use local file or network
      if (widget.isLocalFile) {
        _videoController = VideoPlayerController.file(
          File(widget.videoUrl),
        );
      } else {
        final fixedUrl = UrlHelper.fixImageUrl(widget.videoUrl);
        if (fixedUrl == null) {
          throw Exception('Không tìm thấy video hợp lệ để phát');
        }
        _videoController = VideoPlayerController.network(fixedUrl);
      }
      
      // Initialize with timeout
      await _videoController!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Video tải quá lâu, vui lòng thử lại');
        },
      );

      if (!mounted) return;

      // Create chewie controller with custom settings
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        aspectRatio: _videoController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF1E88E5),
          handleColor: const Color(0xFF1E88E5),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể phát video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Không thể tải video. Vui lòng kiểm tra kết nối mạng.';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Video Player',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Video Player
          Expanded(
            child: Container(
              color: Colors.black,
              child: _buildVideoPlayer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể phát video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Show thumbnail while loading if available
          if (widget.thumbnailUrl != null)
            FutureBuilder<Map<String, String>>(
              future: UrlHelper.getHeaders(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final resolvedUrl = UrlHelper.fixImageUrl(widget.thumbnailUrl!);
                if (resolvedUrl == null) {
                  return const SizedBox.shrink();
                }
                return Image.network(
                  resolvedUrl,
                  headers: snapshot.data,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Đang tải video...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Show video player with chewie
    return Center(
      child: _chewieController != null
          ? Chewie(controller: _chewieController!)
          : const CircularProgressIndicator(color: Colors.white),
    );
  }
}
