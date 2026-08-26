// Copy this file to lib/firebase_options.dart and replace the placeholder
// values, or regenerate lib/firebase_options.dart with FlutterFire CLI.
// Do not commit real Firebase API keys if this repository is public.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:web:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'your-firebase-project-id',
    authDomain: 'your-firebase-project-id.firebaseapp.com',
    storageBucket: 'your-firebase-project-id.appspot.com',
    measurementId: 'G-REPLACE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:android:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'your-firebase-project-id',
    storageBucket: 'your-firebase-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:ios:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'your-firebase-project-id',
    storageBucket: 'your-firebase-project-id.appspot.com',
    iosBundleId: 'com.example.speakery',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:ios:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'your-firebase-project-id',
    storageBucket: 'your-firebase-project-id.appspot.com',
    iosBundleId: 'com.example.speakery',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'replace-me',
    appId: '1:000000000000:web:replace-me',
    messagingSenderId: '000000000000',
    projectId: 'your-firebase-project-id',
    authDomain: 'your-firebase-project-id.firebaseapp.com',
    storageBucket: 'your-firebase-project-id.appspot.com',
    measurementId: 'G-REPLACE',
  );
}
