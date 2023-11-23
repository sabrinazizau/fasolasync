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
    apiKey: 'AIzaSyCyXc8Xa2eIFLalf76BvZ3cjlGyOW8Qznk',
    appId: '1:698775586986:web:77754a9563bd204770e8d3',
    messagingSenderId: '698775586986',
    projectId: 'fasolasync',
    authDomain: 'fasolasync.firebaseapp.com',
    storageBucket: 'fasolasync.appspot.com',
    measurementId: 'G-25F471YLRK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_cua89cLe2AN914-co7MSo-Z7bzvjCJ8',
    appId: '1:698775586986:android:0950ee489063ad0d70e8d3',
    messagingSenderId: '698775586986',
    projectId: 'fasolasync',
    storageBucket: 'fasolasync.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbCialHfxDZZVHNEWr49azvbZpPH4YCjY',
    appId: '1:698775586986:ios:a0ce8fbff07a09e170e8d3',
    messagingSenderId: '698775586986',
    projectId: 'fasolasync',
    storageBucket: 'fasolasync.appspot.com',
    iosBundleId: 'com.example.tugas5',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbCialHfxDZZVHNEWr49azvbZpPH4YCjY',
    appId: '1:698775586986:ios:dd155247853e59fa70e8d3',
    messagingSenderId: '698775586986',
    projectId: 'fasolasync',
    storageBucket: 'fasolasync.appspot.com',
    iosBundleId: 'com.example.tugas5.RunnerTests',
  );
}
