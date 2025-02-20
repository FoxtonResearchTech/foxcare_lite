// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyABRq95_C3XwbylyNiNlmyGJk5fHBhe2Vc',
    appId: '1:1096335735322:web:aa3e4a689703aafdd6efa3',
    messagingSenderId: '1096335735322',
    projectId: 'foxcarelite-a948c',
    authDomain: 'foxcarelite-a948c.firebaseapp.com',
    storageBucket: 'foxcarelite-a948c.firebasestorage.app',
    measurementId: 'G-GLNMKRSFWQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnvVNLDBfmq4i8vW_hE41fWgMKXeOytXQ',
    appId: '1:1096335735322:android:d69ddc82022fc079d6efa3',
    messagingSenderId: '1096335735322',
    projectId: 'foxcarelite-a948c',
    storageBucket: 'foxcarelite-a948c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD027EOFFjzmBoIo4bdrHPPgQOsVEOIwX0',
    appId: '1:1096335735322:ios:aedcbbc4efd21e84d6efa3',
    messagingSenderId: '1096335735322',
    projectId: 'foxcarelite-a948c',
    storageBucket: 'foxcarelite-a948c.firebasestorage.app',
    iosBundleId: 'com.example.foxcareLite',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD027EOFFjzmBoIo4bdrHPPgQOsVEOIwX0',
    appId: '1:1096335735322:ios:aedcbbc4efd21e84d6efa3',
    messagingSenderId: '1096335735322',
    projectId: 'foxcarelite-a948c',
    storageBucket: 'foxcarelite-a948c.firebasestorage.app',
    iosBundleId: 'com.example.foxcareLite',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABRq95_C3XwbylyNiNlmyGJk5fHBhe2Vc',
    appId: '1:1096335735322:web:5a6f90ac0466afddd6efa3',
    messagingSenderId: '1096335735322',
    projectId: 'foxcarelite-a948c',
    authDomain: 'foxcarelite-a948c.firebaseapp.com',
    storageBucket: 'foxcarelite-a948c.firebasestorage.app',
    measurementId: 'G-4TDMSRJ44N',
  );
}
