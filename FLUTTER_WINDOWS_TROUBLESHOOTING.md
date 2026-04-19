# 🚀 Flutter Windows Build Troubleshooting Guide

## Common Windows Build Issues & Solutions

### 1. PathAccessException / Access Denied Errors

**Symptoms:**
- `PathAccessException: Cannot delete file`
- `OS Error: Access is denied`
- `Cannot create a file when that file already exists`

**Solutions:**

#### Quick Fix:
```bash
flutter run --android-skip-build-dependency-validation
```

#### Complete Fix:
1. **Run Force Clean Script:**
   ```bash
   flutter_force_clean.bat
   ```

2. **Run Windows Build Script:**
   ```bash
   flutter_windows_build.bat
   ```

3. **Manual Steps:**
   - Close all file explorers with build folders open
   - Run as Administrator
   - Add antivirus exclusions for project folder
   - Restart computer if file locks persist

### 2. Kotlin Version Warnings

**Fixed:** Updated to Kotlin 2.1.0 in `android/settings.gradle.kts`

### 3. Asset File Copy Errors

**Symptoms:**
- `PathExistsException: Cannot copy file`
- `Cannot create a file when that file already exists (errno = 183)`
- `Cannot copy file to flutter_assets`

**Root Causes:**
- Windows file locking (Explorer, IDE, antivirus)
- Case-sensitivity issues with asset names
- NTFS file system restrictions

**Solutions:**
1. **Quick Fix:** Use `--android-skip-build-dependency-validation` flag
2. **Complete Fix:** Run `reset_build.bat` or `reset_build.ps1`
3. **Manual Steps:**
   - Close all File Explorer windows
   - Close Android Studio/VS Code
   - Run as Administrator
   - Delete build folders manually
4. **Nuclear Option:** Rename the problematic asset file

### 4. Build Scripts Available

- `flutter_windows_build.bat` - Main build script with Windows optimizations
- `flutter_force_clean.bat` - Force clean script for stubborn file locks
- `flutter_troubleshoot.bat` - Comprehensive troubleshooting script
- `reset_build.bat` - **NEW!** Complete reset script for asset file locking issues
- `reset_build.ps1` - **NEW!** PowerShell version of reset script

### 5. Prevention Tips

1. **Always use the Windows build script** for consistent builds
2. **Don't open build folders** in File Explorer during builds
3. **Add antivirus exclusions** for your project and Flutter SDK
4. **Run as Administrator** if you encounter permission issues
5. **Use the skip validation flag** for problematic builds

### 6. Emergency Commands

If all else fails:
```bash
# Nuclear option - restart everything
reset_build.bat
# OR PowerShell version:
# reset_build.ps1

# Alternative:
flutter_force_clean.bat
flutter run --android-skip-build-dependency-validation --verbose
```

### 7. Asset File Locking - Specific Solutions

**For `logo_wuth_circle_Red.png` errors specifically:**

1. **Close all applications** that might be using the file
2. **Run reset script:** `reset_build.bat`
3. **If still failing:** Rename the asset file temporarily:
   ```yaml
   # In pubspec.yaml, temporarily change:
   flutter_launcher_icons:
     image_path: "assets/logo_wuth_circle_white_backup.png"
   ```
4. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run --android-skip-build-dependency-validation
   ```

## ✅ Success Indicators

- No Kotlin version warnings
- No access denied errors
- Clean build completion
- App runs successfully on device
