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
      default:
        // Fallback to web if platform is not recognized
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB123JXEQMYvP2_vSlaM35k0Qg7EgT2AX0',
    appId: '1:624206197788:web:a0c3d7c3338cd915969bd9',
    messagingSenderId: '624206197788',
    projectId: 'sippy-15ef7',
    authDomain: 'sippy-15ef7.firebaseapp.com',
    storageBucket: 'sippy-15ef7.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB123JXEQMYvP2_vSlaM35k0Qg7EgT2AX0',
    appId: '1:624206197788:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '624206197788',
    projectId: 'sippy-15ef7',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB123JXEQMYvP2_vSlaM35k0Qg7EgT2AX0',
    appId: '1:624206197788:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '624206197788',
    projectId: 'sippy-15ef7',
  );
}
