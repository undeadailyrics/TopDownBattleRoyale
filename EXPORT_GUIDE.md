# Android APK Export Guide

This guide walks you through exporting the Top Down Battle Royale game to an Android APK.

## Prerequisites

### 1. Install Required Tools

- **Godot 4.1+**: Download from [godotengine.org](https://godotengine.org)
- **Java Development Kit (JDK)**: Version 11 or higher
- **Android SDK**: API level 21+ (Android 5.1)
- **Android NDK**: r23 or later (for native code compilation)

### 2. Configure Godot

1. Open Godot and go to **Editor → Editor Layout → Default** (if needed)
2. Navigate to **Project → Project Settings → Export**
3. If Android export template isn't installed:
   - Click **Add Export Preset**
   - Select **Android**
   - Click **Install Android Build Template**

## Export Configuration

### Step 1: Set Up Export Preset

1. Go to **Project → Export**
2. Click **Add Preset** and select **Android**
3. In the **Presets** tab, configure the following:

#### General Settings
```
Name: Android Release
Export Path: ./builds/game.apk
Gradle Build: YES
```

#### Android Settings
```
Package Name: com.undeadailyrics.battleryale
Version Code: 1
Version Name: 0.1.0
Min SDK: 21
Target SDK: 33
Permissions: INTERNET, ACCESS_NETWORK_STATE, RECORD_AUDIO
```

#### Display Settings
```
Allow Resizable Window: YES
Use Immersive Mode: YES
Orientation: Sensor (auto-rotate disabled for this game)
```

#### Input Settings
```
Gamepad Support: Enabled
Touchscreen Support: Enabled
```

### Step 2: Configure Android SDK/NDK Paths

1. Go to **Project → Project Settings → Debug**
2. Configure the following paths:
   - **Android Sdk Path**: `/path/to/android-sdk`
   - **Android Ndk Path**: `/path/to/android-ndk-r23`
   - **Java Home Path**: `/path/to/jdk-11`

**macOS Example:**
```
Android Sdk Path: ~/Library/Android/sdk
Android Ndk Path: ~/Library/Android/ndk/23.1.7779620
Java Home Path: /Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home
```

**Windows Example:**
```
Android Sdk Path: C:\Android\sdk
Android Ndk Path: C:\Android\ndk\23.1.7779620
Java Home Path: C:\Program Files\Java\jdk-11
```

**Linux Example:**
```
Android Sdk Path: ~/Android/sdk
Android Ndk Path: ~/Android/ndk/23.1.7779620
Java Home Path: /usr/lib/jvm/java-11-openjdk-amd64
```

## Exporting the APK

### Method 1: Manual Export (Recommended for First Build)

1. Go to **Project → Export**
2. Select the **Android** preset you created
3. Click **Export Project**
4. Choose output directory (e.g., `./builds/`)
5. Godot will build the APK (this takes 2-5 minutes)

The exported APK will be at `./builds/game.apk`

### Method 2: One-Click Export

1. Ensure your export preset is configured
2. Go to **File → Export and Run**
3. Select **Android**
4. Godot will build and install on connected device/emulator

## Testing the APK

### On Android Device

1. Enable **Developer Mode**:
   - Go to Settings → About Phone
   - Tap **Build Number** 7 times
   - Go back to Settings → Developer Options
   - Enable **USB Debugging**

2. Connect device via USB cable

3. Use ADB to install:
```bash
adb install builds/game.apk
```

4. Launch the app from home screen

### On Android Emulator

1. Open Android Studio
2. Create/open an Android Virtual Device (AVD)
3. Install APK:
```bash
adb install -r builds/game.apk
```

## Troubleshooting

### "No JDK found"
- Ensure JAVA_HOME environment variable is set correctly
- Verify Java 11+ is installed: `java -version`

### "Android SDK not found"
- Download Android SDK from Android Studio
- Set the correct path in Godot settings

### "Build failed: NDK not found"
- Download NDK r23+ from Android Developer website
- Ensure NDK path points to the correct version

### "Permission denied" (macOS/Linux)
- Grant execute permissions: `chmod +x /path/to/ndk/ndk-build`

### APK installs but crashes on launch
- Check Godot console for error messages
- Enable **Development Build** in export settings
- Use `adb logcat` to view device logs:
```bash
adb logcat | grep godot
```

## Optimization Tips

### Reduce APK Size

1. In **Project → Project Settings → GDScript**:
   - Enable **Compress Binary Metadata**
   - Set **Bytecode Compression** to DEFLATE

2. Remove unused assets before export

3. Use Godot's resource optimizer:
   - Go to **Project → Optimize**

### Improve Performance

1. Set target FPS in `project.godot`:
```ini
[rendering]
textures/vram_compression/import_etc2_astc=true
quality/driver/fallback_to_gles2=false
```

2. Enable GPU-based skinning for characters

3. Use LOD (Level of Detail) for distant enemies

## Publishing to Google Play Store

### Signed APK (Required for Play Store)

1. Create keystore:
```bash
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias game_key
```

2. In Godot export settings:
   - **Keystore Path**: `release.keystore`
   - **Keystore User**: (your password)
   - **Keystore Password**: (your password)

3. Export as signed APK

4. Upload to Google Play Console

## Next Steps

- Test on multiple device types
- Gather user feedback
- Iterate on game balance
- Consider publishing to other stores (Amazon Appstore, Samsung Galaxy Store)

---

**Questions?** Check the [Godot Documentation](https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_android.html)
