# Build và Debug Release APK

## 1. Clean build
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 2. Build Release APK
```bash
flutter build apk --release
```

## 3. Install và check logs
```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Clear logs
adb logcat -c

# Watch logs (run before opening app)
adb logcat | findstr "flutter"
```

## 4. Nếu app crash ngay khi mở

### Check crash log:
```bash
adb logcat | findstr "AndroidRuntime"
```

### Check ProGuard issues:
```bash
adb logcat | findstr "ClassNotFoundException"
adb logcat | findstr "NoSuchMethodException"
```

## 5. Build với symbols để debug
```bash
flutter build apk --release --split-per-abi
```

## 6. Analyze APK size
```bash
flutter build apk --analyze-size
```

## Common Issues:

### 1. JSON Serialization bị stripped
- **Triệu chứng**: App crash khi parse JSON
- **Giải pháp**: Đã thêm ProGuard rules để keep model classes

### 2. Missing permissions
- **Triệu chứng**: App crash khi access camera/storage
- **Giải pháp**: Đã thêm permissions vào AndroidManifest.xml

### 3. Multidex required
- **Triệu chứng**: App crash với "Cannot fit requested classes"
- **Giải pháp**: Đã enable multidex trong build.gradle.kts

### 4. Native library issues
- **Triệu chứng**: UnsatisfiedLinkError
- **Giải pháp**: Build với `--split-per-abi` hoặc check plugin compatibility

## Build for specific architectures:
```bash
# ARM 64-bit only (modern devices)
flutter build apk --target-platform android-arm64 --release

# All architectures
flutter build apk --split-per-abi --release
```

## Size optimization:
```bash
# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```
