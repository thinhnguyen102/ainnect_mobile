@echo off
REM Run app in Production Environment
echo Running app with PRODUCTION environment...
echo API URL: https://api.ainnect.me/api

flutter run --dart-define=ENVIRONMENT=production

pause
