
#!/bin/bash
set -e

echo "Building Deep Sea Odyssey APK..."

# Clean
flutter clean
flutter pub get

# Build APK (Release mode)
# In a real scenario, we would setup signing configs in android/app/build.gradle
# For now, we build a release APK which might be unsigned or signed with debug key depending on config,
# but usually 'flutter build apk' produces a release build.
flutter build apk --release

echo "Build Complete!"
echo "APK located at: build/app/outputs/flutter-apk/app-release.apk"
