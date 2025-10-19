import 'package:broomie/core/models/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn? _googleSignIn;

  // Existing code...

  /// Save user to Firestore 'users' collection
  Future<void> saveUserToDb(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final appUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
    );
    await userDoc.set(appUser.toMap(), SetOptions(merge: true));
  }

  /// Update signInWithGoogle to save user
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCred;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCred = await _auth.signInWithPopup(googleProvider);
      } else {
        _googleSignIn ??= GoogleSignIn.standard();
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCred = await _auth.signInWithCredential(credential);
      }

      if (userCred.user != null) {
        await saveUserToDb(userCred.user!);
      }

      return userCred;
    } catch (e) {
      print("Google sign-in error: $e");
      rethrow;
    }
  }

  /// Update email sign up to save user
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await saveUserToDb(userCred.user!);
    return userCred;
  }

  Future<AppUser?> getCurrentUserFromDb(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }
}
