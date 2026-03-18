import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAiFU1ZW9NRhuxI2diPoVAuy9tsX8c3_IE',
    appId: '1:261261806531:web:fdeac809905aa4d3e70b76',
    messagingSenderId: '261261806531',
    projectId: 'spades-ordering-system',
    authDomain: 'spades-ordering-system.firebaseapp.com',
    storageBucket: 'spades-ordering-system.firebasestorage.app',
    measurementId: 'G-SD985ZBZ0G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAM160SW8VPfoaFkmAH9XTZQaT9L3wQkMc',
    appId: '1:261261806531:android:275300818c7fc1f0e70b76',
    messagingSenderId: '261261806531',
    projectId: 'spades-ordering-system',
    storageBucket: 'spades-ordering-system.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjETT2l0XV09RNxCiE1WnIXR8f9Rbi788',
    appId: '1:261261806531:ios:6d2867701909e14ae70b76',
    messagingSenderId: '261261806531',
    projectId: 'spades-ordering-system',
    storageBucket: 'spades-ordering-system.firebasestorage.app',
    iosBundleId: 'com.example.spadesOrderingSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjETT2l0XV09RNxCiE1WnIXR8f9Rbi788',
    appId: '1:261261806531:ios:6d2867701909e14ae70b76',
    messagingSenderId: '261261806531',
    projectId: 'spades-ordering-system',
    storageBucket: 'spades-ordering-system.firebasestorage.app',
    iosBundleId: 'com.example.spadesOrderingSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAiFU1ZW9NRhuxI2diPoVAuy9tsX8c3_IE',
    appId: '1:261261806531:web:6a81a7ade1e84ab1e70b76',
    messagingSenderId: '261261806531',
    projectId: 'spades-ordering-system',
    authDomain: 'spades-ordering-system.firebaseapp.com',
    storageBucket: 'spades-ordering-system.firebasestorage.app',
    measurementId: 'G-BE5KBTN3LL',
  );

}