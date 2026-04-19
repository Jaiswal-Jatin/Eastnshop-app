@echo off
echo 🧹 Cleaning Flutter build cache...
flutter clean

echo 📦 Getting dependencies...
flutter pub get

echo 🚀 Running Flutter app...
flutter run

echo ✅ Build completed successfully!
pause
