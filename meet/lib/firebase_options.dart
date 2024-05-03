// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'API here',
    appId: '1:751514024569:web:faf49f63c5825f1ba1b2a8',
    messagingSenderId: '751514024569',
    projectId: 'meet-cs442',
    authDomain: 'meet-cs442.firebaseapp.com',
    storageBucket: 'meet-cs442.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'API Here',
    appId: '1:751514024569:android:d12fd3d9d32adea2a1b2a8',
    messagingSenderId: '751514024569',
    projectId: 'meet-cs442',
    storageBucket: 'meet-cs442.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'API Here',
    appId: '1:751514024569:ios:2093bd0190cb454da1b2a8',
    messagingSenderId: '751514024569',
    projectId: 'meet-cs442',
    storageBucket: 'meet-cs442.appspot.com',
    iosBundleId: 'com.example.meet',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'API Here',
    appId: '1:751514024569:ios:98555a870d5390e8a1b2a8',
    messagingSenderId: '751514024569',
    projectId: 'meet-cs442',
    storageBucket: 'meet-cs442.appspot.com',
    iosBundleId: 'com.example.meet.RunnerTests',
  );
}
