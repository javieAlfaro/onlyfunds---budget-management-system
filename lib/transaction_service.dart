import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a transaction and update the monthly summary
  Future<void> addTransaction({
    required String label,
    required String category,
    String? description,
    required double amount,
    required String type, // "income" or "expense"
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final String monthId = _getMonthId();
    final DateTime now = DateTime.now();

    // References
    final monthRef = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(monthId);

    final summaryRef = monthRef.collection("summary").doc("record");

    // Check balance before expense
    final summarySnapshot = await summaryRef.get();
    double currentBalance = 0.0;
    if (summarySnapshot.exists) {
      final data = summarySnapshot.data() as Map<String, dynamic>;
      currentBalance = (data["balance"] ?? 0).toDouble();
    }

    if (type == "expense" && amount > currentBalance) {
      throw Exception(
          "Insufficient balance. Cannot record expense greater than current balance.");
    }

    // 1. Add transaction
    await monthRef.collection("transactions").add({
      "label": label,
      "category": category,
      "description": description ?? '',
      "amount": amount,
      "type": type,
      "date_added": now,
    });

    // 2. Update summary atomically
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryRef);

      if (!snapshot.exists) {
        transaction.set(summaryRef, {
          "totalIncome": type == "income" ? amount : 0,
          "totalExpense": type == "expense" ? amount : 0,
          "balance": type == "income" ? amount : 0,
          "targetSavings": 0.0, // initial target savings
          "amountSaved": 0.0,   // initial saved amount
          "lastUpdated": now,
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        double totalIncome = (data["totalIncome"] ?? 0).toDouble();
        double totalExpense = (data["totalExpense"] ?? 0).toDouble();
        double targetSavings = (data["targetSavings"] ?? 0).toDouble();
        double amountSaved = (data["amountSaved"] ?? 0).toDouble();

        if (type == "income") {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }

        final newBalance =
            (totalIncome - totalExpense).clamp(0, double.infinity);

        transaction.update(summaryRef, {
          "totalIncome": totalIncome,
          "totalExpense": totalExpense,
          "balance": newBalance,
          "targetSavings": targetSavings,
          "amountSaved": amountSaved,
          "lastUpdated": now,
        });
      }
    });
  }

  /// Get transactions for the current month only
  Stream<QuerySnapshot> getUserTransactions() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(_getMonthId())
        .collection("transactions")
        .orderBy("date_added", descending: true)
        .snapshots();
  }

  /// Streams for current month's totals in summary/record
  Stream<double> currentMonthBalance() => _getSummaryField("balance");
  Stream<double> currentMonthIncome() => _getSummaryField("totalIncome");
  Stream<double> currentMonthExpense() => _getSummaryField("totalExpense");
  Stream<double> currentMonthTargetSavings() => _getSummaryField("targetSavings");
  Stream<double> currentMonthAmountSaved() => _getSummaryField("amountSaved");

  Stream<double> _getSummaryField(String field) {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(_getMonthId())
        .collection("summary")
        .doc("record")
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0.0;
      final data = doc.data() as Map<String, dynamic>;
      return (data[field] ?? 0).toDouble();
    });
  }

  String _getMonthId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  Future<void> deductFromBalance({
  required double amount,
  String label = "Savings",
  String category = "Funds",
  String description = "",
}) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("No user logged in");

  final String monthId = _getMonthId();
  final DateTime now = DateTime.now();

  final monthRef = _firestore
      .collection("users")
      .doc(user.uid)
      .collection("monthly_records")
      .doc(monthId);

  final summaryRef = monthRef.collection("summary").doc("record");
  final transactionsRef = monthRef.collection("transactions");

  await _firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(summaryRef);
    if (!snapshot.exists) {
      throw Exception("Summary record not found for this month");
    }

    final data = snapshot.data() as Map<String, dynamic>;
    double totalExpense = (data["totalExpense"] ?? 0).toDouble();
    double balance = (data["balance"] ?? 0).toDouble();

    if (amount > balance) {
      throw Exception("Insufficient balance");
    }

    totalExpense += amount;
    final newBalance = (balance - amount).clamp(0, double.infinity);

    // Update monthly summary
    transaction.update(summaryRef, {
      "totalExpense": totalExpense,
      "balance": newBalance,
      "lastUpdated": now,
    });

    // Record deduction as an expense transaction
    transaction.set(transactionsRef.doc(), {
      "label": label,
      "category": category,
      "description": description,
      "amount": amount,
      "type": "expense",
      "date_added": now,
    });
  });
}
}