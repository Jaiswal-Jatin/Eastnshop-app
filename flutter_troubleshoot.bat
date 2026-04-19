@echo off
echo ========================================
echo 🔧 Flutter Troubleshooting Script
echo ========================================
echo.

echo 🧹 Cleaning everything...
flutter clean
flutter pub cache clean
flutter pub cache repair

echo 📦 Reinstalling dependencies...
flutter pub get

echo 🔍 Checking Flutter doctor...
flutter doctor -v

echo 🚀 Attempting to run with validation skip...
flutter run --android-skip-build-dependency-validation

pause
