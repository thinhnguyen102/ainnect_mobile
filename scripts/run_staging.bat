@echo off
REM Run app in Staging Environment
echo Running app with STAGING environment...
echo API URL: https://api-stg.ainnect.me/api

flutter run --dart-define=ENVIRONMENT=staging

pause
