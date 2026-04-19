@echo off
echo ========================================
echo 🧹 Flutter Force Clean Script
echo ========================================
echo.

echo 🛑 Stopping any running Flutter processes...
taskkill /f /im flutter.exe 2>nul
taskkill /f /im dart.exe 2>nul
taskkill /f /im gradle.exe 2>nul
taskkill /f /im java.exe 2>nul

echo 🧹 Cleaning Flutter build cache...
flutter clean

echo 🗑️ Manually removing build directories...
if exist "build" rmdir /s /q "build" 2>nul
if exist ".dart_tool" rmdir /s /q ".dart_tool" 2>nul
if exist "android\build" rmdir /s /q "android\build" 2>nul
if exist "android\app\build" rmdir /s /q "android\app\build" 2>nul
if exist "android\.gradle" rmdir /s /q "android\.gradle" 2>nul

echo 📦 Getting dependencies...
flutter pub get

echo ✅ Force clean completed!
echo 💡 Now try running: flutter run --android-skip-build-dependency-validation
pause
