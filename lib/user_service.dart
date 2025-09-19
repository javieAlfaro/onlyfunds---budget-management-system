import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserRecord({
    required String uid,
    required String username,
    required String email,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "user_name": username,
      "email": email,
      "date_created": FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _firestore.collection("users").doc(uid).get();
  }
}