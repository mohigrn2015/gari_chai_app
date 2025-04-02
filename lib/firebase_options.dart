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
    apiKey: 'AIzaSyAkedIhSP4tH6d48tRUU3a1wm3qgsPNejY',
    appId: '1:730293875447:web:95a5f656bb4dcd06a3d9f2',
    messagingSenderId: '730293875447',
    projectId: 'garichai-53a76',
    authDomain: 'garichai-53a76.firebaseapp.com',
    storageBucket: 'garichai-53a76.firebasestorage.app',
    measurementId: 'G-RR96H75Z1J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoVSxyC0LSxwBC3jJD-q8H9P1xPxVa2tI',
    appId: '1:730293875447:android:3bb6ce988f628b17a3d9f2',
    messagingSenderId: '730293875447',
    projectId: 'garichai-53a76',
    storageBucket: 'garichai-53a76.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBWQ3RDgaSYJxPcjbUko9gDYfWXKfClfpo',
    appId: '1:730293875447:ios:3d3aeb4087d7b030a3d9f2',
    messagingSenderId: '730293875447',
    projectId: 'garichai-53a76',
    storageBucket: 'garichai-53a76.firebasestorage.app',
    iosBundleId: 'com.example.gariChai',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBWQ3RDgaSYJxPcjbUko9gDYfWXKfClfpo',
    appId: '1:730293875447:ios:3d3aeb4087d7b030a3d9f2',
    messagingSenderId: '730293875447',
    projectId: 'garichai-53a76',
    storageBucket: 'garichai-53a76.firebasestorage.app',
    iosBundleId: 'com.example.gariChai',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAkedIhSP4tH6d48tRUU3a1wm3qgsPNejY',
    appId: '1:730293875447:web:b1ea8800778a1573a3d9f2',
    messagingSenderId: '730293875447',
    projectId: 'garichai-53a76',
    authDomain: 'garichai-53a76.firebaseapp.com',
    storageBucket: 'garichai-53a76.firebasestorage.app',
    measurementId: 'G-T4ENNH9W54',
  );

}