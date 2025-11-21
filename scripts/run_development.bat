@echo off
REM Run app in Development Environment
echo Running app with DEVELOPMENT environment...
echo API URL: http://10.0.2.2:8080/api

flutter run --dart-define=ENVIRONMENT=development

pause
