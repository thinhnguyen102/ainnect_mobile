@echo off
REM Build for Production Environment
echo Building for PRODUCTION environment...
echo API URL: https://api.ainnect.me/api

REM Build APK for production
flutter build apk --dart-define=ENVIRONMENT=production --release

echo.
echo Production APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
pause
