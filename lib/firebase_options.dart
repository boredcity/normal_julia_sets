// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-fdwVi_kRCgNq1jE2W_FBT5nv01tdCMw',
    appId: '1:819253415293:web:9906abb5fb0d641ab25014',
    messagingSenderId: '819253415293',
    projectId: 'julia-sets',
    authDomain: 'julia-sets.firebaseapp.com',
    storageBucket: 'julia-sets.appspot.com',
    measurementId: 'G-HK04KY2CCE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBv33uiyp9kfnTBFFFLfh8cNWJRoTyBTmc',
    appId: '1:819253415293:android:a66c5108ae1c6fa5b25014',
    messagingSenderId: '819253415293',
    projectId: 'julia-sets',
    storageBucket: 'julia-sets.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwfEkW7j1kIA3_FLDxeUXBX7HW1jj2KrM',
    appId: '1:819253415293:ios:7f4e7ae6be3f743cb25014',
    messagingSenderId: '819253415293',
    projectId: 'julia-sets',
    storageBucket: 'julia-sets.appspot.com',
    iosClientId: '819253415293-9igdkajutqr73j4oqps1i4ta0f396n4d.apps.googleusercontent.com',
    iosBundleId: 'com.merelj.julia.sets.normal-julia-sets',
  );
}
