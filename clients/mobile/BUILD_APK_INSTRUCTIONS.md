# Building APK File - Instructions

## Current Issue
Gradle is trying to download dependencies but encountering timeout issues. Here are several solutions:

## Solution 1: Build APK (Recommended - Running in Background)
The build process has been started in the background. It will:
1. Download Gradle 8.12 (first time only, ~200MB)
2. Download Android dependencies (~500MB)
3. Build the APK file

**Expected time**: 5-15 minutes for first build

**APK Location** (when complete):
```
clients/mobile/build/app/outputs/flutter-apk/app-debug.apk
```

## Solution 2: Manual Build Steps

### Step 1: Pre-download Gradle (Optional but Recommended)
```bash
cd clients/mobile/android
./gradlew --version
```
This will download Gradle distribution first, then you can build.

### Step 2: Build APK
```bash
cd clients/mobile
flutter build apk --debug
```

### Step 3: Find Your APK
```bash
ls -lh build/app/outputs/flutter-apk/app-debug.apk
```

## Solution 3: Build for Specific Architecture (Faster)
If you only need to test on a specific device:

```bash
# For ARM64 devices (most modern phones)
flutter build apk --debug --target-platform android-arm64

# For ARM32 devices (older phones)
flutter build apk --debug --target-platform android-arm

# For x86_64 (emulators)
flutter build apk --debug --target-platform android-x64
```

## Solution 4: Build Release APK (Smaller, Optimized)
For production/testing:
```bash
flutter build apk --release
```
**Location**: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### If Gradle Download Times Out:

1. **Check Internet Connection**
   - Gradle needs to download ~700MB on first build
   - Ensure stable internet connection

2. **Manually Download Gradle**:
   ```bash
   # Download Gradle 8.12 manually
   mkdir -p ~/.gradle/wrapper/dists/gradle-8.12-all/ejduaidbjup3bmmkhw3rie4zb
   cd ~/.gradle/wrapper/dists/gradle-8.12-all/ejduaidbjup3bmmkhw3rie4zb
   wget https://services.gradle.org/distributions/gradle-8.12-all.zip
   ```

3. **Use Gradle from System** (if installed):
   ```bash
   # Check if Gradle is installed
   gradle --version
   
   # If yes, you can use it directly
   cd clients/mobile/android
   gradle assembleDebug
   ```

4. **Increase Timeout** (if needed):
   Edit `android/gradle.properties` and add:
   ```
   systemProp.org.gradle.internal.http.connectionTimeout=300000
   systemProp.org.gradle.internal.http.socketTimeout=300000
   ```

### If Build Fails:

1. **Clean and Rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

2. **Check Disk Space**:
   ```bash
   df -h
   ```
   Need at least 5GB free space

3. **Check Java Version**:
   ```bash
   java -version
   ```
   Should be Java 11 or higher

## Quick Commands Summary

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# Split APKs by architecture (smaller files)
flutter build apk --split-per-abi

# Check build status
ps aux | grep gradle
```

## APK File Locations

- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Split APKs**: `build/app/outputs/flutter-apk/app-<abi>-debug.apk`

## Transfer APK to Phone

1. **Via USB**:
   ```bash
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

2. **Via File Transfer**:
   - Copy APK to phone via USB/Bluetooth
   - Enable "Install from Unknown Sources" on phone
   - Open APK file on phone to install

3. **Via ADB Push**:
   ```bash
   adb push build/app/outputs/flutter-apk/app-debug.apk /sdcard/Download/
   ```

## Note
The first build always takes longer (5-15 minutes) because it downloads:
- Gradle distribution (~200MB)
- Android SDK components (~300MB)
- Dependencies (~200MB)

Subsequent builds are much faster (1-3 minutes) as they use cached files.

