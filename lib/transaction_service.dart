import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTransaction({
    required String label,
    required String category,
    String? description,
    required double amount,
    required String type, // "income" or "expense"
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .add({
      "label": label,
      "category": category,
      "description": description ?? '',
      "amount": amount,
      "type": type,
      "date_added": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserTransactions() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    }
    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .orderBy("date_added", descending: true)
        .limit(5)
        .snapshots();
  }
}