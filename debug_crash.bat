@echo off
echo ====================================
echo Debug APK Crash - AINnect
echo ====================================
echo.
echo Connecting to device and reading crash logs...
echo.
adb logcat -d | findstr "AndroidRuntime"
echo.
echo ====================================
echo Full filtered log:
echo ====================================
adb logcat -d | findstr "ainnect"
echo.
echo ====================================
echo To get real-time logs, run:
echo adb logcat | findstr "AndroidRuntime"
echo ====================================
pause
