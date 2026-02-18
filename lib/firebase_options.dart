// File generated manually from android/app/google-services.json
// Project: drape-and-glow (516636428857)
//
// ⚠️  iOS: Register the iOS app in your Firebase console (drape-and-glow),
//    download GoogleService-Info.plist → ios/Runner/ and re-run
//    `flutterfire configure --project=drape-and-glow` to replace this file.
//
// DO NOT commit real API keys to public repositories.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured yet. Add the web app in Firebase Console '
        'and run `flutterfire configure --project=drape-and-glow`.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        // iOS app not yet registered. Register it in Firebase Console and
        // add GoogleService-Info.plist to ios/Runner/.
        throw UnsupportedError(
          'iOS is not configured yet. Register the iOS app in Firebase Console '
          '(drape-and-glow) and run `flutterfire configure --project=drape-and-glow`.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android ──────────────────────────────────────────────────────────────
  // Source: android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxctajQO-bkO3airGEPlGiUfaopc8q0D8',
    appId: '1:516636428857:android:169823b09d5ee4fb2c5be8',
    messagingSenderId: '516636428857',
    projectId: 'drape-and-glow',
    storageBucket: 'drape-and-glow.firebasestorage.app',
  );
}
