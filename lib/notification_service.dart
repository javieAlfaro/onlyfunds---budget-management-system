// services/basic_notification_service.dart
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _notificationsEnabled = true;

  // Individual notification settings
  bool _spendingAlertsEnabled = true;
  bool _savingsAlertsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _reminderAlertsEnabled = true;
  bool _insightAlertsEnabled = true;

  // Store notification history
  final List<Map<String, dynamic>> _notifications = [];

  // Show notification as a beautiful dialog
  void showNotificationDialog(BuildContext context, {
    required String title,
    required String message,
    required Color color,
  }) {
    if (!_notificationsEnabled) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                _getNotificationIcon(title),
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Store in history
    _notifications.add({
      'title': title,
      'message': message,
      'timestamp': DateTime.now(),
      'read': false,
    });
  }

  // Show notification as snackbar
  void showNotificationSnackBar(BuildContext context, {
    required String title,
    required String message,
    required Color color,
  }) {
    if (!_notificationsEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_getNotificationIcon(title), size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Store in history
    _notifications.add({
      'title': title,
      'message': message,
      'timestamp': DateTime.now(),
      'read': false,
    });
  }

  // Get appropriate icon for notification type
  IconData _getNotificationIcon(String title) {
    if (title.contains('🚨')) return Icons.warning_rounded;
    if (title.contains('💰')) return Icons.savings_rounded;
    if (title.contains('📊')) return Icons.analytics_rounded;
    if (title.contains('📝')) return Icons.notifications_active_rounded;
    if (title.contains('📈')) return Icons.trending_up_rounded;
    if (title.contains('💸')) return Icons.attach_money_rounded;
    return Icons.notifications_rounded;
  }

  // NOTIFICATION METHODS WITH SETTINGS CHECK
  void showSpendingAlert(BuildContext context, {
    required String category,
    required double amount,
    required double budgetLimit,
  }) {
    if (!_spendingAlertsEnabled) return;
    showNotificationSnackBar(
      context,
      title: '🚨 Spending Alert',
      message: 'You spent ₱${amount.toStringAsFixed(0)} on $category - ${((amount / budgetLimit) * 100).toStringAsFixed(0)}% of budget',
      color: Colors.orange,
    );
  }

  void showSavingsReminder(BuildContext context, {
    required double currentAmount,
    required double targetAmount,
    required int daysLeft,
  }) {
    if (!_savingsAlertsEnabled) return;
    final progress = (currentAmount / targetAmount * 100).toStringAsFixed(1);
    showNotificationSnackBar(
      context,
      title: '💰 Savings Update',
      message: 'You saved ₱${currentAmount.toStringAsFixed(0)} (${progress}%) of your goal. $daysLeft days left!',
      color: Colors.green,
    );
  }

  void showBudgetWarning(BuildContext context, {
    required String category,
    required double spentPercentage,
    required int daysLeftInMonth,
  }) {
    if (!_budgetAlertsEnabled) return;
    String message;
    Color color = Colors.orange;
    
    if (spentPercentage > 90) {
      message = 'You used ${spentPercentage.toStringAsFixed(0)}% of $category budget with $daysLeftInMonth days left!';
      color = Colors.red;
    } else if (spentPercentage > 75) {
      message = 'You used ${spentPercentage.toStringAsFixed(0)}% of $category budget. Consider slowing down.';
    } else {
      return;
    }

    showNotificationSnackBar(
      context,
      title: '📊 Budget Alert',
      message: message,
      color: color,
    );
  }

  void showDailyReminder(BuildContext context) {
    if (!_reminderAlertsEnabled) return;
    showNotificationSnackBar(
      context,
      title: '📝 OnlyFunds Reminder',
      message: 'Don\'t forget to log your transactions for today!',
      color: Colors.blue,
    );
  }

  void showWeeklyInsight(BuildContext context, {
    required String insight,
    required String recommendation,
  }) {
    if (!_insightAlertsEnabled) return;
    showNotificationDialog(
      context,
      title: '📈 Weekly Insight',
      message: '$insight\n\n💡 $recommendation',
      color: Colors.purple,
    );
  }

  void showIncomeExpenseAlert(BuildContext context, {
    required double income,
    required double expenses,
    required double savings,
  }) {
    if (!_insightAlertsEnabled) return;
    final savingsRate = income > 0 ? (savings / income * 100) : 0;
    String message;
    Color color = Colors.green;
    
    if (savingsRate > 20) {
      message = 'Excellent! You saved ${savingsRate.toStringAsFixed(1)}% of your income this month.';
    } else if (savingsRate > 0) {
      message = 'You saved ${savingsRate.toStringAsFixed(1)}% of your income. Every bit counts!';
    } else {
      message = 'Your expenses exceeded income this month. Review your spending.';
      color = Colors.red;
    }

    showNotificationDialog(
      context,
      title: '💸 Monthly Summary',
      message: message,
      color: color,
    );
  }

  // SETTINGS MANAGEMENT
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
  }

  void updateNotificationSettings({
    bool? spendingAlerts,
    bool? savingsAlerts,
    bool? budgetAlerts,
    bool? reminderAlerts,
    bool? insightAlerts,
  }) {
    if (spendingAlerts != null) _spendingAlertsEnabled = spendingAlerts;
    if (savingsAlerts != null) _savingsAlertsEnabled = savingsAlerts;
    if (budgetAlerts != null) _budgetAlertsEnabled = budgetAlerts;
    if (reminderAlerts != null) _reminderAlertsEnabled = reminderAlerts;
    if (insightAlerts != null) _insightAlertsEnabled = insightAlerts;

    print('Notification settings updated:');
    print('Spending Alerts: $_spendingAlertsEnabled');
    print('Savings Alerts: $_savingsAlertsEnabled');
    print('Budget Alerts: $_budgetAlertsEnabled');
    print('Reminder Alerts: $_reminderAlertsEnabled');
    print('Insight Alerts: $_insightAlertsEnabled');
  }

  // GETTERS FOR SETTINGS (optional - if you want to display current settings)
  bool get spendingAlertsEnabled => _spendingAlertsEnabled;
  bool get savingsAlertsEnabled => _savingsAlertsEnabled;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  bool get reminderAlertsEnabled => _reminderAlertsEnabled;
  bool get insightAlertsEnabled => _insightAlertsEnabled;

  List<Map<String, dynamic>> getNotificationHistory() {
    return _notifications;
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index]['read'] = true;
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
  }
}