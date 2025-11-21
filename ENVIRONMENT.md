# Environment Configuration

Ainnect Mobile hỗ trợ 3 môi trường: **Development**, **Staging**, và **Production**.

## 🌍 Môi trường

| Môi trường | API URL | Mô tả |
|-----------|---------|-------|
| **Development** | `http://10.0.2.2:8080/api` | Backend local, dành cho phát triển |
| **Staging** | `https://api-stg.ainnect.me/api` | Môi trường test trước production |
| **Production** | `https://api.ainnect.me/api` | Môi trường chính thức |

## 🚀 Cách sử dụng

### 1. Run từ VS Code (Recommended)

Click vào **Run and Debug** (Ctrl+Shift+D) và chọn:
- `Development (Local)` - Backend local
- `Staging` - API staging
- `Production` - API production

### 2. Run từ Scripts (Windows)

```bash
# Development
scripts\run_development.bat

# Staging
scripts\run_staging.bat

# Production
scripts\run_production.bat
```

### 3. Run từ Command Line

```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Staging
flutter run --dart-define=ENVIRONMENT=staging

# Production
flutter run --dart-define=ENVIRONMENT=production
```

## 📦 Build APK

### Staging
```bash
# Sử dụng script
scripts\build_staging.bat

# Hoặc command line
flutter build apk --dart-define=ENVIRONMENT=staging --release
```

### Production
```bash
# Sử dụng script
scripts\build_production.bat

# Hoặc command line
flutter build apk --dart-define=ENVIRONMENT=production --release
```

APK được tạo tại: `build\app\outputs\flutter-apk\app-release.apk`

## 📱 Build App Bundle (Google Play)

```bash
# Staging
flutter build appbundle --dart-define=ENVIRONMENT=staging --release

# Production
flutter build appbundle --dart-define=ENVIRONMENT=production --release
```

App Bundle được tạo tại: `build\app\outputs\bundle\release\app-release.aab`

## 🔍 Kiểm tra môi trường

### Trong app
Khi chạy ở môi trường Development hoặc Staging, app sẽ hiển thị:
- Banner góc trên bên phải với tên môi trường
- Bar màu ở top hiển thị môi trường và API URL

### Trong code
```dart
import 'package:ainnect/utils/server_config.dart';

print('Environment: ${ServerConfig.currentEnvironment}');
print('API URL: ${ServerConfig.baseUrl}');
```

### Console logs
Khi app khởi động, console sẽ log:
```
🌍 Environment: staging
🔗 API URL: https://api-stg.ainnect.me/api
```

## 🎨 Visual Indicators

| Môi trường | Màu Banner | Hiển thị |
|-----------|-----------|----------|
| Development | 🟢 Green | DEV - http://10.0.2.2:8080/api |
| Staging | 🟠 Orange | STAGING - https://api-stg.ainnect.me/api |
| Production | ❌ None | Không hiển thị banner |

## 📝 Lưu ý

1. **Mặc định**: Nếu không chỉ định `ENVIRONMENT`, app sẽ dùng **Development**
2. **Production**: Không hiển thị environment banner để UX tốt hơn
3. **API Authentication**: Tất cả môi trường đều yêu cầu JWT token
4. **WebSocket**: URL tự động chuyển từ `https://` → `wss://` và `http://` → `ws://`

## 🔧 Cấu hình

Cấu hình môi trường nằm trong file `lib/utils/server_config.dart`:

```dart
class ServerConfig {
  static const String productionApiUrl = 'https://api.ainnect.me/api';
  static const String stagingApiUrl = 'https://api-stg.ainnect.me/api';
  static const String developmentApiUrl = 'http://10.0.2.2:8080/api';
  
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
}
```

Để thay đổi URL, sửa các constant trong file này.

## 🐛 Troubleshooting

### Lỗi: "Cannot connect to server"
- ✅ Kiểm tra môi trường đang chạy
- ✅ Đảm bảo backend server đang chạy
- ✅ Kiểm tra network/internet connection
- ✅ Dev: Backend phải chạy ở `localhost:8080`

### Lỗi: "Environment banner không hiển thị"
- Banner chỉ hiển thị ở Development và Staging
- Production không có banner

### Lỗi: "Wrong API URL"
```bash
# Kiểm tra log khi app start
🌍 Environment: staging
🔗 API URL: https://api-stg.ainnect.me/api
```

Nếu URL sai, rebuild app với đúng `--dart-define=ENVIRONMENT=<env>`

## 📚 Tham khảo thêm

- Chi tiết scripts: `scripts/README.md`
- VS Code configuration: `.vscode/launch.json`
- Server config: `lib/utils/server_config.dart`
