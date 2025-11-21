# Build Scripts cho Ainnect Mobile

Thư mục này chứa các script để build và run app với các môi trường khác nhau.

## Môi trường

### 1. Development (Dev)
- **API URL**: `http://10.0.2.2:8080/api`
- **Mô tả**: Môi trường phát triển local, kết nối tới backend chạy trên máy local
- **Run**: `scripts\run_development.bat`

### 2. Staging (STG)
- **API URL**: `https://api-stg.ainnect.me/api`
- **Mô tả**: Môi trường staging để test trước khi release production
- **Run**: `scripts\run_staging.bat`
- **Build APK**: `scripts\build_staging.bat`

### 3. Production (Prod)
- **API URL**: `https://api.ainnect.me/api`
- **Mô tả**: Môi trường production cho người dùng cuối
- **Run**: `scripts\run_production.bat`
- **Build APK**: `scripts\build_production.bat`

## Cách sử dụng

### Run app (Debug mode)

#### Development
```bash
cd scripts
run_development.bat
```

#### Staging
```bash
cd scripts
run_staging.bat
```

#### Production
```bash
cd scripts
run_production.bat
```

### Build APK (Release mode)

#### Staging
```bash
cd scripts
build_staging.bat
```
APK sẽ được tạo tại: `build\app\outputs\flutter-apk\app-release.apk`

#### Production
```bash
cd scripts
build_production.bat
```
APK sẽ được tạo tại: `build\app\outputs\flutter-apk\app-release.apk`

## Run từ Command Line

Bạn cũng có thể run trực tiếp từ terminal:

### Development
```bash
flutter run --dart-define=ENVIRONMENT=development
```

### Staging
```bash
flutter run --dart-define=ENVIRONMENT=staging
```

### Production
```bash
flutter run --dart-define=ENVIRONMENT=production
```

## Build từ Command Line

### Build APK Staging
```bash
flutter build apk --dart-define=ENVIRONMENT=staging --release
```

### Build APK Production
```bash
flutter build apk --dart-define=ENVIRONMENT=production --release
```

### Build App Bundle (cho Google Play)
```bash
# Staging
flutter build appbundle --dart-define=ENVIRONMENT=staging --release

# Production
flutter build appbundle --dart-define=ENVIRONMENT=production --release
```

## Kiểm tra môi trường hiện tại

Trong code, bạn có thể kiểm tra môi trường hiện tại:

```dart
import 'package:ainnect/utils/server_config.dart';

void checkEnvironment() {
  print('Current environment: ${ServerConfig.currentEnvironment}');
  print('API URL: ${ServerConfig.baseUrl}');
}
```

## VS Code Launch Configuration

Thêm vào `.vscode/launch.json` để run từ VS Code:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENVIRONMENT=development"]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENVIRONMENT=staging"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define=ENVIRONMENT=production"]
    }
  ]
}
```

## Lưu ý

- **Development**: Mặc định khi chạy `flutter run` mà không có dart-define
- **Staging**: Dùng để test với data staging trước khi release production
- **Production**: Chỉ build khi đã test kỹ và sẵn sàng release

## Troubleshooting

### Lỗi "ENVIRONMENT not found"
Đảm bảo bạn đã truyền `--dart-define=ENVIRONMENT=<env>` khi build/run.

### API connection failed
Kiểm tra:
1. URL có đúng không
2. Network/Internet connection
3. Backend server có đang chạy không
4. Firewall/VPN có block không
