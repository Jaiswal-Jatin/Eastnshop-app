# Flutter Reset Build Script (PowerShell)
# Run this script as Administrator for best results

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🧹 Flutter Reset Build Script (PowerShell)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🛑 Stopping any running Flutter processes..." -ForegroundColor Yellow
Get-Process -Name "flutter" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dart" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "gradle" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "🗑️ Manually deleting build directories..." -ForegroundColor Yellow
$folders = @("build", ".dart_tool", "android\build", "android\app\build", "android\.gradle")

foreach ($folder in $folders) {
    if (Test-Path $folder) {
        Write-Host "Deleting $folder folder..." -ForegroundColor Red
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "🧹 Running Flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "🚀 Running Flutter app..." -ForegroundColor Yellow
flutter run --android-skip-build-dependency-validation

Write-Host "✅ Reset build completed!" -ForegroundColor Green
Read-Host "Press Enter to continue"
