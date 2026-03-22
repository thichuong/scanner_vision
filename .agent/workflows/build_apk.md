---
description: Build Android APK for the Flutter app
---

1. Clear existing build artifacts
```bash
flutter clean
```
// turbo

2. Get necessary dependencies
```bash
flutter pub get
```
// turbo

3. Build the release APK
```bash
flutter build apk --release
```

4. Notify the user that the APK has been built successfully and can be found at `build/app/outputs/flutter-apk/app-release.apk`.
