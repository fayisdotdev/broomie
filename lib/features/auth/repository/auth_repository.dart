// ...existing code...
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:broomie/core/models/auth_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn? _googleSignIn; // lazy init, avoid web assertion

  /// Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current logged-in user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google (mobile + web)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCred;
      if (kIsWeb) {
        // Web: Use Firebase popup (no google_sign_in_web client init required here)
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCred = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: initialize lazily
        _googleSignIn ??= GoogleSignIn.standard();
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) return null; // user cancelled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCred = await _auth.signInWithCredential(credential);
      }

      // Save user to Firestore when newly signed in
      if (userCred.user != null) {
        await saveUserToDb(userCred.user!);
      }

      return userCred;
    } catch (e) {
      // Use proper logging instead of print in production
      print("Google sign-in error: $e");
      rethrow;
    }
  }

  /// Sign in with email & password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Email sign-in error: $e");
      rethrow;
    }
  }

  /// Sign up with email & password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Save new user to Firestore
      if (userCred.user != null) {
        await saveUserToDb(userCred.user!);
      }
      return userCred;
    } catch (e) {
      print("Email sign-up error: $e");
      rethrow;
    }
  }

  /// Sign out (mobile + web)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (!kIsWeb) {
        await _googleSignIn?.signOut();
      }
    } catch (e) {
      print("Sign-out error: $e");
      rethrow;
    }
  }

  /// 🔹 Phone authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException) onError,
    required Function(PhoneAuthCredential) onAutoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onAutoVerify,
      verificationFailed: onError,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final userCred = await _auth.signInWithCredential(credential);
    if (userCred.user != null) {
      await saveUserToDb(userCred.user!);
    }
    return userCred;
  }

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
}
