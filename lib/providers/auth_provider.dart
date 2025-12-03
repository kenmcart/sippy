import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _firebaseInitialized = false;

  User? get user => _user;
  bool get isAuthenticated => _firebaseInitialized && _user != null;
  String? get userEmail => _user?.email;
  String? get userName => _user?.displayName ?? _user?.email?.split('@')[0];
  bool get firebaseInitialized => _firebaseInitialized;

  AuthProvider() {
    // Don't initialize here - wait for Firebase to be ready
  }

  void _tryInitializeAuth() {
    try {
      // Check if Firebase is actually initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('❌ Firebase apps list is empty - Firebase not initialized');
        _firebaseInitialized = false;
        notifyListeners();
        return;
      }
      
      debugPrint('✅ Firebase apps found: ${Firebase.apps.length}');
      _auth = FirebaseAuth.instance;
      _firebaseInitialized = true;
      _auth!.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
      debugPrint('✅ Firebase Auth initialized successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Firebase Auth not available: $e');
      debugPrint('Stack trace: $stackTrace');
      _firebaseInitialized = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    // Wait a bit to ensure Firebase.initializeApp() has completed
    await Future.delayed(const Duration(milliseconds: 1000));
    
    debugPrint('🔍 Initializing AuthProvider...');
    debugPrint('Firebase apps count: ${Firebase.apps.length}');
    
    // Try multiple times with delays
    for (int i = 0; i < 3; i++) {
      if (!_firebaseInitialized) {
        debugPrint('Attempt ${i + 1} to initialize Firebase Auth...');
        _tryInitializeAuth();
        if (_firebaseInitialized) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    if (_firebaseInitialized && _auth != null) {
      try {
        _user = _auth!.currentUser;
        debugPrint('✅ Current user: ${_user?.email ?? "none"}');
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Error getting current user: $e');
      }
    } else {
      debugPrint('❌ Firebase Auth not initialized after 3 attempts');
      debugPrint('Firebase apps: ${Firebase.apps.length}');
      debugPrint('Firebase apps names: ${Firebase.apps.map((app) => app.name).join(", ")}');
      // Print to console for browser visibility
      print('FIREBASE_AUTH_INIT_FAILED: Apps count = ${Firebase.apps.length}');
    }
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    if (!_firebaseInitialized || _auth == null) {
      return 'Firebase is not configured. Please set up Firebase first.';
    }
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    if (!_firebaseInitialized || _auth == null) {
      return 'Firebase is not configured. Please set up Firebase first.';
    }
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();
        _user = _auth!.currentUser;
      }
      
      _user = credential.user;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    if (_firebaseInitialized && _auth != null) {
      try {
        await _auth!.signOut();
      } catch (e) {
        debugPrint('Error signing out: $e');
      }
    }
    _user = null;
    notifyListeners();
  }

  Future<String?> resetPassword(String email) async {
    if (!_firebaseInitialized || _auth == null) {
      return 'Firebase is not configured. Please set up Firebase first.';
    }
    try {
      await _auth!.sendPasswordResetEmail(email: email.trim());
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

