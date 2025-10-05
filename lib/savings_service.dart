import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a new savings goal for the current month
  Future<void> addSavingsGoal({
  required String category,
  required double amount,
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

  final goalsRef = monthRef.collection("goals").doc(category);
  final summaryRef = monthRef.collection("summary").doc("record");

  // Read all goals outside transaction to calculate totalTargetSavings safely
  final allGoalsSnapshot = await monthRef.collection("goals").get();
  double totalTargetSavings = allGoalsSnapshot.docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc.data()["amount"]?.toDouble() ?? 0.0));

  // Get current goal amount for this category
  final goalSnapshot = await goalsRef.get();
  double newGoalAmount = amount;
  if (goalSnapshot.exists) {
    newGoalAmount += (goalSnapshot.data()?["amount"]?.toDouble() ?? 0.0);
  }

  // Update/add goal
  await goalsRef.set({
    "amount": newGoalAmount,
    "lastUpdated": now,
  });

  // Update summary document
  final summarySnapshot = await summaryRef.get();
  double amountSaved = summarySnapshot.exists
      ? (summarySnapshot.data()?["amountSaved"] ?? 0.0)
      : 0.0;

  await summaryRef.set({
    "totalIncome": summarySnapshot.data()?["totalIncome"] ?? 0.0,
    "totalExpense": summarySnapshot.data()?["totalExpense"] ?? 0.0,
    "balance": summarySnapshot.data()?["balance"] ?? 0.0,
    "targetSavings": totalTargetSavings - (goalSnapshot.exists ? (goalSnapshot.data()?["amount"]?.toDouble() ?? 0.0) : 0.0) + newGoalAmount,
    "amountSaved": amountSaved,
    "lastUpdated": now,
  });
}



  /// Update the amount saved for the month
  Future<void> updateAmountSaved(double amount) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final String monthId = _getMonthId();
    final DateTime now = DateTime.now();

    final summaryRef = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(monthId)
        .collection("summary")
        .doc("record");

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(summaryRef);

      if (!snapshot.exists) {
        transaction.set(summaryRef, {
          "totalIncome": 0.0,
          "totalExpense": 0.0,
          "balance": 0.0,
          "targetSavings": 0.0,
          "amountSaved": amount,
          "lastUpdated": now,
        });
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        double currentSaved = (data["amountSaved"] ?? 0).toDouble();
        double newSaved = currentSaved + amount;

        transaction.update(summaryRef, {
          "amountSaved": newSaved,
          "lastUpdated": now,
        });
      }
    });
  }

  /// Get savings goal for a category
  Stream<DocumentSnapshot> getGoal(String category) {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final monthId = _getMonthId();
    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(monthId)
        .collection("goals")
        .doc(category)
        .snapshots();
  }

  /// Get summary (totalIncome, totalExpense, balance, targetSavings, amountSaved)
  Stream<DocumentSnapshot> getSummary() {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final monthId = _getMonthId();
    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(monthId)
        .collection("summary")
        .doc("record")
        .snapshots();
  }

  String _getMonthId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  Future<double> totalTarget() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final monthId = _getMonthId();
    final goalsSnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(monthId)
        .collection("goals")
        .get();

    double total = 0.0;
    for (var doc in goalsSnapshot.docs) {
      total += (doc.data()["amount"]?.toDouble() ?? 0.0);
    }
    return total;
  }

  /// Returns the total amount already saved for the current month
  Future<double> totalSaved() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final monthId = _getMonthId();
    final summaryRef = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("monthly_records")
        .doc(monthId)
        .collection("summary")
        .doc("record");

    final snapshot = await summaryRef.get();
    if (!snapshot.exists) return 0.0;

    return (snapshot.data()?["amountSaved"]?.toDouble() ?? 0.0);
  }

  Stream<double> currentAmountSaved() => _getSummaryField("amountSaved");
  Stream<double> currentTargetSavings() => _getSummaryField("targetSavings");
  
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

  Stream<double> savedAmount(String category) {
  final user = _auth.currentUser;
  if (user == null) throw Exception("No user logged in");

  final monthId = _getMonthId();
  return _firestore
      .collection("users")
      .doc(user.uid)
      .collection("monthly_records")
      .doc(monthId)
      .collection("goals")
      .doc(category)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return 0.0;
    final data = doc.data() as Map<String, dynamic>;
    return (data["amount"]?.toDouble() ?? 0.0);
  });
}
}
