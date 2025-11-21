@echo off
REM Build for Staging Environment
echo Building for STAGING environment...
echo API URL: https://api-stg.ainnect.me/api

REM Build APK for staging
flutter build apk --dart-define=ENVIRONMENT=staging --release

echo.
echo Staging APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
pause
