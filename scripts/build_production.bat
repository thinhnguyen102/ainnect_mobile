@echo off
REM Build for Production Environment
\\\\\\echo ========================================
echo Building for PRODUCTION environment...
echo API URL: https://api.ainnect.me/api
echo ========================================
echo.

REM Clean previous build
echo Cleaning previous build...
call flutter clean
echo.

REM Get dependencies
echo Getting dependencies...
call flutter pub get
echo.

REM Build APK for production
echo Building APK with PRODUCTION environment...
echo Command: flutter build apk --dart-define=ENVIRONMENT=production --release
echo.
flutter build apk --dart-define=ENVIRONMENT=production --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Production APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Build FAILED!
    echo Please check the error messages above.
    echo ========================================
)

pause
