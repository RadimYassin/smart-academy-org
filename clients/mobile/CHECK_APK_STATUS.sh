#!/bin/bash
# Script to check APK build status

echo "=== Checking APK Build Status ==="
echo ""

# Check if APK exists
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    echo "✅ APK Generated Successfully!"
    echo "📦 Location: $APK_PATH"
    echo "📊 Size: $(ls -lh $APK_PATH | awk '{print $5}')"
    echo ""
    echo "To install on your phone:"
    echo "  adb install $APK_PATH"
    echo ""
    echo "Or copy to phone:"
    echo "  cp $APK_PATH ~/Downloads/"
else
    echo "⏳ APK not yet generated - build in progress..."
    echo ""
    echo "Checking build process..."
    if pgrep -f "flutter build" > /dev/null; then
        echo "✅ Flutter build process is running"
    else
        echo "❌ No Flutter build process found"
    fi
    
    if pgrep -f "gradle" > /dev/null; then
        echo "✅ Gradle process is running"
    else
        echo "❌ No Gradle process found"
    fi
    echo ""
    echo "To check build logs:"
    echo "  tail -f android/.gradle/*.log"
    echo ""
    echo "To restart build:"
    echo "  flutter build apk --debug"
fi

