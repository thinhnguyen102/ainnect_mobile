import 'dart:async';
import 'dart:io';
import 'package:minio/minio.dart';
import 'dart:typed_data';

class CloudflareR2Uploader {
  final String accessKey;
  final String secretKey;
  final String accountId;
  final String bucketName;
  final String publicUrl;

  late final Minio _minio;

  CloudflareR2Uploader({
    required this.accessKey,
    required this.secretKey,
    required this.accountId,
    required this.bucketName,
    required this.publicUrl,
  }) {
    final endpoint = '$accountId.r2.cloudflarestorage.com';
    _minio = Minio(
      endPoint: endpoint,
      accessKey: accessKey,
      secretKey: secretKey,
      useSSL: true,
      region: 'auto',
 );
  }

  /// Uploads a file to Cloudflare R2 and returns the public CDN URL
  Future<String> uploadFile(File file, {String? key}) async {
    final fileKey = key ?? file.uri.pathSegments.last;
    final contentType = _getContentType(fileKey);
    final stream = file.openRead().map((data) => Uint8List.fromList(data));
    final length = await file.length();
    print('[CloudflareR2Uploader] Uploading file: $fileKey');
    print('[CloudflareR2Uploader] Content-Type: $contentType');
    print('[CloudflareR2Uploader] File size: $length bytes');
    print('[CloudflareR2Uploader] Bucket: $bucketName');
    try {
      await _minio.putObject(
        bucketName,
        fileKey,
        stream,
        metadata: {'Content-Type': contentType},
      );
      print('[CloudflareR2Uploader] Upload successful: $fileKey');
      return '$publicUrl/$fileKey';
    } catch (e, stack) {
      print('[CloudflareR2Uploader] Upload failed: $e');
      print(stack);
      rethrow;
    }
  }

  String _getContentType(String filename) {
    final ext = filename.toLowerCase();
    if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) return 'image/jpeg';
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.gif')) return 'image/gif';
    if (ext.endsWith('.webp')) return 'image/webp';
    if (ext.endsWith('.mp4')) return 'video/mp4';
    if (ext.endsWith('.mov')) return 'video/quicktime';
    if (ext.endsWith('.mkv')) return 'video/x-matroska';
    return 'application/octet-stream';
  }
}
