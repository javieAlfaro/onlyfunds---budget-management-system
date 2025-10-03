import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add transaction + update monthly balance
  Future<void> addTransaction({
    required String label,
    required String category,
    String? description,
    required double amount,
    required String type, // "income" or "expense"
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    DateTime now = DateTime.now();
    String monthId = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final monthlyDocRef = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_balances")
        .doc(monthId);

    // Check balance before expense
    final monthlySnapshot = await monthlyDocRef.get();
    double currentBalance = 0.0;
    if (monthlySnapshot.exists) {
      final data = monthlySnapshot.data() as Map<String, dynamic>;
      currentBalance = (data["balance"] ?? 0).toDouble();
    }

    if (type == "expense" && amount > currentBalance) {
      throw Exception(
          "Insufficient balance. Cannot record expense greater than current balance.");
    }

    // 1. Add transaction
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
      "date_added": now,
    });

    // 2. Update monthly balance
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(monthlyDocRef);

      if (!snapshot.exists) {
        // Create new doc for this month
        transaction.set(monthlyDocRef, {
          "totalIncome": type == "income" ? amount : 0,
          "totalExpense": type == "expense" ? amount : 0,
          "balance": type == "income" ? amount : 0, 
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        double totalIncome = (data["totalIncome"] ?? 0).toDouble();
        double totalExpense = (data["totalExpense"] ?? 0).toDouble();

        if (type == "income") {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }

        final newBalance =
            (totalIncome - totalExpense).clamp(0, double.infinity);

        transaction.update(monthlyDocRef, {
          "totalIncome": totalIncome,
          "totalExpense": totalExpense,
          "balance": newBalance,
        });
      }
    });
  }

  /// Get last 5 transactions
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

  /// Stream for current month's balance
  Stream<double> currentMonthBalance() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    }

    DateTime now = DateTime.now();
    String monthId = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_balances")
        .doc(monthId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0.0;
      final data = doc.data() as Map<String, dynamic>;
      return (data["balance"] ?? 0).toDouble();
    });
  }

  /// Stream for current month's total income
  Stream<double> currentMonthIncome() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    DateTime now = DateTime.now();
    String monthId = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_balances")
        .doc(monthId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0.0;
      final data = doc.data() as Map<String, dynamic>;
      return (data["totalIncome"] ?? 0).toDouble();
    });
  }

  /// Stream for current month's total expense
  Stream<double> currentMonthExpense() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    DateTime now = DateTime.now();
    String monthId = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_balances")
        .doc(monthId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0.0;
      final data = doc.data() as Map<String, dynamic>;
      return (data["totalExpense"] ?? 0).toDouble();
    });
  }
}
