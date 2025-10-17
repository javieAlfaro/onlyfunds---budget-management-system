// services/analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Alert Thresholds
  static const double budgetWarning = 0.75;
  static const double budgetCritical = 0.90;
  static const double savingsGoalProgress = 0.5;
  static const double spendingSpike = 2.0;
  static const double incomeDrop = 0.3;

  // Priority categories for special focus
  static const List<String> priorityCategories = [
    "Food/Grocery",
    "Transportation", 
    "Utility Bills",
    "Subscriptions",
    "Shopping/Other"
  ];

  /// Get comprehensive financial insights for reports
  Future<Map<String, dynamic>> getFinancialInsights(String userId) async {
    final transactions = await _getHistoricalTransactions(userId, months: 6);
    
    if (transactions.isEmpty) {
      return _getEmptyInsights();
    }

    final basicInsights = _getBasicFinancialMetrics(transactions);
    final predictions = await _predictFutureExpenses(transactions);
    final recommendations = _getPersonalizedRecommendations(transactions, basicInsights);
    final alerts = _generateRealTimeAlerts(basicInsights);

    return {
      'basicMetrics': basicInsights,
      'predictions': predictions,
      'recommendations': recommendations,
      'alerts': alerts,
      'spendingTrends': _analyzeSpendingTrends(transactions),
      'categoryBreakdown': _getCategoryBreakdown(transactions),
      'savingsAnalysis': _analyzeSavingsPattern(transactions, basicInsights),
    };
  }

  /// ML: Expense Prediction using Linear Regression - FIXED VERSION
  Future<Map<String, dynamic>> _predictFutureExpenses(List<Map<String, dynamic>> transactions) async {
    try {
      // Convert to proper numeric types and ensure we have enough data
      final List<List<double>> expenseData = transactions
          .where((t) => _safeConvertToString(t['type']) == 'expense')
          .map((t) {
            final date = t['date'] as DateTime;
            return [date.millisecondsSinceEpoch.toDouble(), _safeConvertToDouble(t['amount'])];
          })
          .toList();

      if (expenseData.length < 10) {
        return {
          'predictedAmount': null,
          'confidence': 0.0,
          'message': 'Need more data for accurate predictions (min 10 transactions)'
        };
      }

      // Create dataframe with proper column names
      final dataframe = DataFrame(
        expenseData,
        header: ['timestamp', 'amount'],
      );
      
      // Train linear regression model
      final model = LinearRegressor(
        dataframe,
        'amount', // target column
        fitIntercept: true,
      );
      
      // Predict for next month
      final nextMonth = DateTime.now().add(const Duration(days: 30));
      final nextMonthTimestamp = nextMonth.millisecondsSinceEpoch.toDouble();
      
      final predictionData = DataFrame(
        [[nextMonthTimestamp]],
        header: ['timestamp'],
      );
      
      final prediction = model.predict(predictionData);
      
      // Extract the prediction value safely
      double predictedAmount = 0.0;
      if (prediction.rows.isNotEmpty && prediction.rows.first.isNotEmpty) {
        predictedAmount = prediction.rows.first.first;
      }

      return {
        'predictedAmount': predictedAmount > 0 ? predictedAmount : null,
        'nextMonth': nextMonth,
        'confidence': _calculatePredictionConfidence(expenseData),
        'trend': _calculateExpenseTrend(expenseData),
      };
    } catch (e) {
      print('ML Prediction error: $e');
      return {
        'error': 'Prediction unavailable',
        'message': 'Add more expense data to enable predictions'
      };
    }
  }

  /// ML: Personalized Budget Recommendations
  Map<String, dynamic> _getPersonalizedRecommendations(
    List<Map<String, dynamic>> transactions, 
    Map<String, dynamic> metrics
  ) {
    final categorySpending = _getCategorySpending(transactions);
    final savingsRate = _safeConvertToDouble(metrics['savingsRate']);
    final totalIncome = _safeConvertToDouble(metrics['totalIncome']);

    final recommendations = <String, Map<String, dynamic>>{};
    String overallAdvice = '';

    // Analyze each priority category
    for (final category in priorityCategories) {
      final spent = _safeConvertToDouble(categorySpending[category]);
      final percentage = totalIncome > 0 ? (spent / totalIncome) * 100 : 0.0;
      
      String advice;
      double suggestedBudget;

      if (percentage > 30) {
        advice = 'High spending area. Consider reducing by 15-20%.';
        suggestedBudget = spent * 0.8; // 20% reduction
      } else if (percentage > 15) {
        advice = 'Moderate spending. Look for optimization opportunities.';
        suggestedBudget = spent * 0.9; // 10% reduction
      } else {
        advice = 'Well controlled. Maintain current level.';
        suggestedBudget = spent;
      }

      recommendations[category] = {
        'currentSpending': spent,
        'percentage': percentage,
        'advice': advice,
        'suggestedBudget': suggestedBudget,
        'potentialSavings': spent - suggestedBudget,
      };
    }

    // Overall financial advice based on savings rate
    if (savingsRate > 20) {
      overallAdvice = 'Excellent savings rate! Consider increasing investments.';
    } else if (savingsRate > 10) {
      overallAdvice = 'Good financial health. Focus on debt reduction if any.';
    } else if (savingsRate > 0) {
      overallAdvice = 'Positive savings. Look for areas to optimize spending.';
    } else {
      overallAdvice = 'Spending exceeds income. Review essential vs. discretionary expenses.';
    }

    return {
      'categoryRecommendations': recommendations,
      'overallAdvice': overallAdvice,
      'savingsRate': savingsRate,
    };
  }

  /// Real-time Alert Generation
  List<Map<String, dynamic>> _generateRealTimeAlerts(Map<String, dynamic> metrics) {
    final alerts = <Map<String, dynamic>>[];
    final currentDate = DateTime.now();
    final daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final daysPassed = currentDate.day;
    final expectedSpendingRatio = daysPassed / daysInMonth;

    final totalExpenses = _safeConvertToDouble(metrics['totalExpenses']);
    final totalIncome = _safeConvertToDouble(metrics['totalIncome']);
    final categorySpending = _safeConvertToMap<String, double>(metrics['categorySpending']);
    final savings = _safeConvertToDouble(metrics['savings']);

    // Budget overspending alerts
    for (final category in priorityCategories) {
      final spent = _safeConvertToDouble(categorySpending[category]);
      final expectedSpent = (_safeConvertToDouble(metrics['averageMonthlyExpense']) * expectedSpendingRatio);
      
      if (spent > expectedSpent * 1.5) {
        alerts.add({
          'type': 'spending_spike',
          'category': category,
          'message': 'Unusual spending spike in $category detected',
          'severity': 'high',
          'amount': spent - expectedSpent,
        });
      }
    }

    // Savings progress alert
    if (savings > 0 && expectedSpendingRatio > savingsGoalProgress) {
      final savingsTarget = (totalIncome * 0.2); // 20% savings target
      if (savings < savingsTarget * savingsGoalProgress) {
        alerts.add({
          'type': 'savings_alert',
          'message': 'You\'re behind on savings goals for this month',
          'severity': 'medium',
          'needed': savingsTarget - savings,
        });
      }
    }

    // Income drop alert (compared to last month average)
    final avgMonthlyIncome = _safeConvertToDouble(metrics['averageMonthlyIncome']);
    if (avgMonthlyIncome > 0 && totalIncome < avgMonthlyIncome * (1 - incomeDrop)) {
      alerts.add({
        'type': 'income_drop',
        'message': 'Income is lower than usual this month',
        'severity': 'medium',
        'dropPercentage': ((avgMonthlyIncome - totalIncome) / avgMonthlyIncome * 100).round(),
      });
    }

    return alerts;
  }

  /// FIXED: Proper type handling for Firestore data
  Future<List<Map<String, dynamic>>> _getHistoricalTransactions(String userId, {int months = 6}) async {
    final List<Map<String, dynamic>> allTransactions = [];
    final now = DateTime.now();
    
    for (int i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i);
      final monthId = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      
      try {
        final querySnapshot = await _firestore
            .collection("users")
            .doc(userId)
            .collection("monthly_records")
            .doc(monthId)
            .collection("transactions")
            .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          
          // SAFE TYPE CONVERSION - don't cast directly
          final transaction = {
            'id': doc.id,
            'amount': _safeConvertToDouble(data['amount']),
            'category': _safeConvertToString(data['category']),
            'type': _safeConvertToString(data['type']),
            'date': data['date_added'] is Timestamp 
                ? (data['date_added'] as Timestamp).toDate()
                : DateTime.now(),
            'label': _safeConvertToString(data['label']),
          };
          
          allTransactions.add(transaction);
        }
      } catch (e) {
        print('Error fetching transactions for $monthId: $e');
      }
    }

    return allTransactions;
  }

  /// FIXED: Safe type conversion methods
  double _safeConvertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  String _safeConvertToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  /// Safe conversion for nested maps
  Map<K, V> _safeConvertToMap<K, V>(dynamic value) {
    if (value == null) return <K, V>{};
    if (value is Map<K, V>) return value;
    if (value is Map) {
      try {
        return Map<K, V>.from(value);
      } catch (e) {
        return <K, V>{};
      }
    }
    return <K, V>{};
  }

  /// FIXED: Safe map access in basic metrics
  Map<String, dynamic> _getBasicFinancialMetrics(List<Map<String, dynamic>> transactions) {
    final expenses = transactions.where((t) => _safeConvertToString(t['type']) == 'expense');
    final income = transactions.where((t) => _safeConvertToString(t['type']) == 'income');

    final totalExpenses = expenses.fold(0.0, (sum, item) => sum + _safeConvertToDouble(item['amount']));
    final totalIncome = income.fold(0.0, (sum, item) => sum + _safeConvertToDouble(item['amount']));
    final savings = totalIncome - totalExpenses;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome) * 100 : 0;

    return {
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'savings': savings,
      'savingsRate': savingsRate,
      'categorySpending': _getCategorySpending(transactions),
      'averageMonthlyExpense': _calculateAverageMonthly(expenses.toList()),
      'averageMonthlyIncome': _calculateAverageMonthly(income.toList()),
      'transactionCount': transactions.length,
    };
  }

  /// FIXED: Safe category spending calculation
  Map<String, double> _getCategorySpending(List<Map<String, dynamic>> transactions) {
    final Map<String, double> categoryMap = {};
    final expenses = transactions.where((t) => _safeConvertToString(t['type']) == 'expense');
    
    for (final expense in expenses) {
      final category = _safeConvertToString(expense['category']);
      final amount = _safeConvertToDouble(expense['amount']);
      
      categoryMap.update(
        category,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }
    
    return categoryMap;
  }

  double _calculateAverageMonthly(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) return 0;
    
    final dates = transactions.map((t) => t['date'] as DateTime? ?? DateTime.now()).toList();
    final firstDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    final months = (lastDate.difference(firstDate).inDays / 30).ceil();
    
    final total = transactions.fold(0.0, (sum, item) => sum + _safeConvertToDouble(item['amount']));
    return total / (months > 0 ? months : 1);
  }

  /// FIXED: Proper type for expenseData
  double _calculatePredictionConfidence(List<List<double>> expenseData) {
    if (expenseData.length < 3) return 0.0;
    // More data and consistent patterns = higher confidence
    final dataPoints = expenseData.length;
    final baseConfidence = (dataPoints / 30).clamp(0.0, 0.8); // Cap at 80% for data quantity
    
    // Calculate consistency (lower variance = higher confidence)
    final amounts = expenseData.map((e) => e[1]).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final variance = amounts.map((a) => (a - mean) * (a - mean)).reduce((a, b) => a + b) / amounts.length;
    final consistency = (1.0 - (variance / (mean > 0 ? mean : 1))).clamp(0.0, 1.0);
    
    return (baseConfidence * 0.6 + consistency * 0.4).clamp(0.0, 1.0);
  }

  /// FIXED: Proper type for expenseData
  String _calculateExpenseTrend(List<List<double>> expenseData) {
    if (expenseData.length < 2) return 'stable';
    
    // Use last 30% of data vs previous 30% for trend calculation
    final recentCount = (expenseData.length * 0.3).ceil();
    final recentData = expenseData.take(recentCount);
    final previousData = expenseData.skip(recentCount).take(recentCount);
    
    if (recentData.isEmpty || previousData.isEmpty) return 'stable';
    
    final recentAvg = recentData.fold(0.0, (sum, item) => sum + item[1]) / recentData.length;
    final previousAvg = previousData.fold(0.0, (sum, item) => sum + item[1]) / previousData.length;
    
    if (previousAvg == 0) return 'stable';
    
    final change = (recentAvg - previousAvg) / previousAvg;
    
    if (change > 0.1) return 'increasing';
    if (change < -0.1) return 'decreasing';
    return 'stable';
  }

  Map<String, dynamic> _analyzeSpendingTrends(List<Map<String, dynamic>> transactions) {
    // Group by month and analyze trends
    final monthlyData = <String, double>{};
    
    for (final transaction in transactions) {
      final date = transaction['date'] as DateTime;
      final monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      
      if (_safeConvertToString(transaction['type']) == 'expense') {
        final amount = _safeConvertToDouble(transaction['amount']);
        monthlyData.update(
          monthKey,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    }
    
    return {
      'monthlySpending': monthlyData,
      'trend': _calculateMonthlyTrend(monthlyData),
    };
  }

  Map<String, double> _getCategoryBreakdown(List<Map<String, dynamic>> transactions) {
    return _getCategorySpending(transactions);
  }

  Map<String, dynamic> _analyzeSavingsPattern(
    List<Map<String, dynamic>> transactions, 
    Map<String, dynamic> metrics
  ) {
    final savingsRate = _safeConvertToDouble(metrics['savingsRate']);
    String profile = 'Balanced';
    
    if (savingsRate > 25) profile = 'Super Saver';
    else if (savingsRate > 15) profile = 'Good Saver';
    else if (savingsRate > 5) profile = 'Moderate Saver';
    else if (savingsRate >= 0) profile = 'Minimal Saver';
    else profile = 'Over Spender';

    return {
      'savingsProfile': profile,
      'savingsRate': savingsRate,
      'recommendedTarget': (_safeConvertToDouble(metrics['totalIncome']) * 0.2), // 20% target
    };
  }

  String _calculateMonthlyTrend(Map<String, double> monthlyData) {
    if (monthlyData.length < 2) return 'stable';
    
    final sortedKeys = monthlyData.keys.toList()..sort();
    final recent = monthlyData[sortedKeys.last] ?? 0.0;
    final previous = monthlyData[sortedKeys[sortedKeys.length - 2]] ?? 0.0;
    
    if (previous == 0) return 'stable';
    
    final change = (recent - previous) / previous;
    
    if (change > 0.05) return 'increasing';
    if (change < -0.05) return 'decreasing';
    return 'stable';
  }

  Map<String, dynamic> _getEmptyInsights() {
    return {
      'basicMetrics': {
        'totalExpenses': 0.0,
        'totalIncome': 0.0,
        'savings': 0.0,
        'savingsRate': 0.0,
        'categorySpending': <String, double>{},
        'averageMonthlyExpense': 0.0,
        'averageMonthlyIncome': 0.0,
        'transactionCount': 0,
      },
      'predictions': {'message': 'Add more transactions to get predictions'},
      'recommendations': {'overallAdvice': 'Start adding transactions to get personalized insights'},
      'alerts': [],
      'spendingTrends': {'trend': 'stable'},
      'categoryBreakdown': <String, double>{},
      'savingsAnalysis': {'savingsProfile': 'New User'},
    };
  }
}