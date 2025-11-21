import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static final Map<String, String> _env = dotenv.env;

  static bool get cloudflareR2Enabled =>
      (_env['CLOUDFLARE_R2_ENABLED'] ?? 'false').toLowerCase() == 'true';

  static String get cloudflareR2AccountId =>
      _env['CLOUDFLARE_R2_ACCOUNT_ID'] ?? '';

  static String get cloudflareR2AccessKeyId =>
      _env['CLOUDFLARE_R2_ACCESS_KEY_ID'] ?? '';

  static String get cloudflareR2SecretAccessKey =>
      _env['CLOUDFLARE_R2_SECRET_ACCESS_KEY'] ?? '';

  static String get cloudflareR2BucketName =>
      _env['CLOUDFLARE_R2_BUCKET_NAME'] ?? '';

  static String get cloudflareR2PublicUrl =>
      _env['CLOUDFLARE_R2_PUBLIC_URL'] ?? '';

  static String get cloudflareR2UploadWorkerUrl =>
      _env['FLUTTER_APP_UPLOAD_WORKER_URL'] ?? '';
}

