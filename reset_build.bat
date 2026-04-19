@echo off
echo ========================================
echo 🧹 Flutter Reset Build Script
echo ========================================
echo.

echo 🛑 Stopping any running Flutter processes...
taskkill /f /im flutter.exe 2>nul
taskkill /f /im dart.exe 2>nul
taskkill /f /im gradle.exe 2>nul
taskkill /f /im java.exe 2>nul

echo 🗑️ Manually deleting build directories...
if exist "build" (
    echo Deleting build folder...
    rd /s /q build
)
if exist ".dart_tool" (
    echo Deleting .dart_tool folder...
    rd /s /q .dart_tool
)
if exist "android\build" (
    echo Deleting android\build folder...
    rd /s /q android\build
)
if exist "android\app\build" (
    echo Deleting android\app\build folder...
    rd /s /q android\app\build
)
if exist "android\.gradle" (
    echo Deleting android\.gradle folder...
    rd /s /q android\.gradle
)

echo 🧹 Running Flutter clean...
flutter clean

echo 📦 Getting dependencies...
flutter pub get

echo 🚀 Running Flutter app...
flutter run --android-skip-build-dependency-validation

echo ✅ Reset build completed!
pause
