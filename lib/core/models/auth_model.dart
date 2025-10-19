import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;

  AppUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
  });

  /// Convert AppUser to Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create AppUser from Firestore document
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
    );
  }
}
