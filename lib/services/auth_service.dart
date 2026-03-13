import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;
    return _fetchAppUser(user.uid);
  }

  Future<AppUser?> register({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;

    await user.updateDisplayName(displayName);

    final appUser = AppUser(
      uid: user.uid,
      email: email.trim(),
      displayName: displayName,
      studentId: studentId,
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(appUser.toMap());
    return appUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> _fetchAppUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, uid);
  }

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchAppUser(user.uid);
  }
}
