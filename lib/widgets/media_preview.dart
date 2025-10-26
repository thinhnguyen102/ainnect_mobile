import 'package:flutter/material.dart';
import '../utils/url_helper.dart';

class MediaPreview extends StatefulWidget {
  final String mediaUrl;
  final String mediaType;
  final VoidCallback? onRemove;

  const MediaPreview({
    super.key,
    required this.mediaUrl,
    required this.mediaType,
    this.onRemove,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  late Future<Map<String, String>> _headersFuture;

  @override
  void initState() {
    super.initState();
    _headersFuture = UrlHelper.getHeaders();
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
                child: widget.mediaType == 'image'
                    ? snapshot.hasData
                        ? Image.network(
                            UrlHelper.fixImageUrl(widget.mediaUrl),
                            headers: snapshot.data,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                              );
                            },
                          )
                        : const Center(child: CircularProgressIndicator())
                    : const Center(
                        child: Icon(Icons.play_circle_outline, size: 40),
                      ),
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
}
