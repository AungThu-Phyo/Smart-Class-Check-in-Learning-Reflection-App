import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _appUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get appUser => _appUser;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _appUser = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _appUser = await _authService.getCurrentAppUser();
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    try {
      _appUser = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
  }) async {
    _errorMessage = null;
    try {
      _appUser = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
        studentId: studentId,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _appUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
