import 'dart:io';

import '../config/env_config.dart';
import 'cloudflare_r2_uploader.dart';

class MediaUploadService {
  final CloudflareR2Uploader? _uploader;
  final String? _errorMessage;

  bool get isAvailable => _uploader != null;
  String? get errorMessage => _errorMessage;

  MediaUploadService._(this._uploader, this._errorMessage);

  factory MediaUploadService() {
    final enabled = EnvConfig.cloudflareR2Enabled;
    if (!enabled) {
      return MediaUploadService._(
        null,
        'Cloudflare R2 upload đã bị tắt (CLOUDFLARE_R2_ENABLED=false)',
      );
    }

    final accountId = EnvConfig.cloudflareR2AccountId;
    final accessKey = EnvConfig.cloudflareR2AccessKeyId;
    final secretKey = EnvConfig.cloudflareR2SecretAccessKey;
    final bucket = EnvConfig.cloudflareR2BucketName;
    final publicUrl = EnvConfig.cloudflareR2PublicUrl;

    final missing = <String>[
      if (accountId.isEmpty) 'CLOUDFLARE_R2_ACCOUNT_ID',
      if (accessKey.isEmpty) 'CLOUDFLARE_R2_ACCESS_KEY_ID',
      if (secretKey.isEmpty) 'CLOUDFLARE_R2_SECRET_ACCESS_KEY',
      if (bucket.isEmpty) 'CLOUDFLARE_R2_BUCKET_NAME',
      if (publicUrl.isEmpty) 'CLOUDFLARE_R2_PUBLIC_URL',
    ];

    if (missing.isNotEmpty) {
      return MediaUploadService._(
        null,
        'Thiếu cấu hình Cloudflare R2: ${missing.join(', ')}',
      );
    }

    return MediaUploadService._(
      CloudflareR2Uploader(
        accessKey: accessKey,
        secretKey: secretKey,
        accountId: accountId,
        bucketName: bucket,
        publicUrl: publicUrl,
      ),
      null,
    );
  }

  Future<String> uploadFile(File file, {String? key}) async {
    final uploader = _uploader;
    if (uploader == null) {
      throw Exception(_errorMessage ?? 'Cloudflare R2 chưa được cấu hình');
    }

    return uploader.uploadFile(file, key: key);
  }
}

