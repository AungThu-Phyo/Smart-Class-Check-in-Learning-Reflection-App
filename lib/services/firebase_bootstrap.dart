import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;
  static String? _lastError;

  static bool get isReady => _initialized;
  static String? get lastError => _lastError;

  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      _initialized = true;
      _lastError = null;
      return true;
    } on FirebaseAuthException catch (error) {
      _initialized = false;
      _lastError = _friendlyAuthError(error);
      return false;
    } catch (error) {
      _initialized = false;
      _lastError = _friendlyGenericError(error);
      return false;
    }
  }

  static String _friendlyAuthError(FirebaseAuthException error) {
    final raw = error.toString();
    final code = error.code.toLowerCase();
    final hasMissingConfig =
        code.contains('configuration-not-found') ||
        raw.toLowerCase().contains('configuration_not_found') ||
        raw.toLowerCase().contains('configuration-not-found');

    if (hasMissingConfig) {
      return 'Firebase Authentication is not configured for this project. '
          'Enable Authentication and turn on Anonymous sign-in in Firebase Console. '
          'Raw error: $raw';
    }

    if (code.contains('operation-not-allowed')) {
      return 'Anonymous sign-in is disabled in Firebase Authentication. '
          'Enable Anonymous provider in Firebase Console. Raw error: $raw';
    }

    if (code.contains('admin-only-operation') ||
        code.contains('admin_only_operation')) {
      return 'This Firebase project currently blocks end-user sign-up operations. '
          'In Firebase Console Authentication settings, allow user sign-up and keep Anonymous sign-in enabled. '
          'Raw error: $raw';
    }

    return 'Firebase authentication failed ($code). Raw error: $raw';
  }

  static String _friendlyGenericError(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();

    if (lower.contains('configuration_not_found') ||
        lower.contains('configuration-not-found')) {
      return 'Firebase Authentication is not configured for this project. '
          'Enable Authentication and Anonymous sign-in in Firebase Console. '
          'Raw error: $raw';
    }

    if (lower.contains('admin_only_operation') ||
        lower.contains('admin-only-operation')) {
      return 'This Firebase project currently blocks end-user sign-up operations. '
          'In Firebase Console Authentication settings, allow user sign-up and keep Anonymous sign-in enabled. '
          'Raw error: $raw';
    }

    return raw;
  }
}
