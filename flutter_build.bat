@echo off
echo ========================================
echo 🚀 Flutter Clean Build Script
echo ========================================
echo.

echo 🧹 Step 1: Cleaning Flutter build cache...
flutter clean
if %errorlevel% neq 0 (
    echo ❌ Flutter clean failed!
    pause
    exit /b 1
)

echo 📦 Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Flutter pub get failed!
    pause
    exit /b 1
)

echo 🔧 Step 3: Checking Flutter doctor...
flutter doctor
if %errorlevel% neq 0 (
    echo ⚠️ Flutter doctor shows issues, but continuing...
)

echo 🚀 Step 4: Running Flutter app...
flutter run
if %errorlevel% neq 0 (
    echo ❌ Flutter run failed!
    echo.
    echo 💡 Try these solutions:
    echo    1. Run as Administrator
    echo    2. Check if antivirus is blocking files
    echo    3. Use: flutter run --android-skip-build-dependency-validation
    pause
    exit /b 1
)

echo ✅ Build completed successfully!
pause
