import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyfunds_v1/ml_analytics_service.dart';
import 'package:onlyfunds_v1/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notificationsEnabled = true;
  final AnalyticsService _analyticsService = AnalyticsService();
  final NotificationService _notificationService = NotificationService();
  
  // Notification categories
  bool _spendingAlertsEnabled = true;
  bool _savingsAlertsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _reminderAlertsEnabled = true;
  bool _insightAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
  // In a real app, you would load these from SharedPreferences
  // For now, we'll use the service's default values
  setState(() {
    _spendingAlertsEnabled = true;
    _savingsAlertsEnabled = true;
    _budgetAlertsEnabled = true;
    _reminderAlertsEnabled = true;
    _insightAlertsEnabled = true;
  });
}

  Future<void> _testNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Test spending alert
    _notificationService.showSpendingAlert(
      context,
      category: "Food/Grocery",
      amount: 1500.0,
      budgetLimit: 1000.0,
    );

    // Wait a bit between notifications
    await Future.delayed(const Duration(milliseconds: 500));

    // Test savings reminder
    _notificationService.showSavingsReminder(
      context,
      currentAmount: 2000.0,
      targetAmount: 5000.0,
      daysLeft: 10,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Test budget warning
    _notificationService.showBudgetWarning(
      context,
      category: "Transportation",
      spentPercentage: 85.0,
      daysLeftInMonth: 15,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Test daily reminder
    _notificationService.showDailyReminder(context);

    await Future.delayed(const Duration(milliseconds: 500));

    // Test weekly insight
    _notificationService.showWeeklyInsight(
      context,
      insight: "Your food spending decreased by 15% this week.",
      recommendation: "Consider allocating the savings to your travel fund!",
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Test income vs expense
    _notificationService.showIncomeExpenseAlert(
      context,
      income: 25000.0,
      expenses: 18000.0,
      savings: 7000.0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notifications completed! Check the notifications above.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _updateNotificationSettings() {
    _notificationService.updateNotificationSettings(
      spendingAlerts: _spendingAlertsEnabled,
      savingsAlerts: _savingsAlertsEnabled,
      budgetAlerts: _budgetAlertsEnabled,
      reminderAlerts: _reminderAlertsEnabled,
      insightAlerts: _insightAlertsEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add, color: Colors.black),
            onPressed: _testNotifications,
            tooltip: 'Test Notifications',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Main Notification Toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text(
                  "Enable In-App Notifications",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text("Turn all app notifications on or off"),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _notificationService.toggleNotifications(value);
                  if (value) {
                    // Update settings when re-enabled
                    _updateNotificationSettings();
                  }
                },
                secondary: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active_rounded 
                      : Icons.notifications_off_rounded,   
                  color: _notificationsEnabled
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey,                         
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notification Categories
            if (_notificationsEnabled) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Notification Types",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Choose what types of notifications you want to receive",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Spending Alerts
              _buildNotificationCategoryCard(
                icon: Icons.trending_up_rounded,
                title: "Spending Alerts",
                subtitle: "Unusual spending patterns & spikes",
                value: _spendingAlertsEnabled,
                onChanged: (value) => setState(() {
                  _spendingAlertsEnabled = value;
                  _updateNotificationSettings();
                }),
              ),

              // Savings Alerts
              _buildNotificationCategoryCard(
                icon: Icons.savings_rounded,
                title: "Savings Goals",
                subtitle: "Progress updates & reminders",
                value: _savingsAlertsEnabled,
                onChanged: (value) => setState(() {
                  _savingsAlertsEnabled = value;
                  _updateNotificationSettings();
                }),
              ),

              // Budget Alerts
              _buildNotificationCategoryCard(
                icon: Icons.account_balance_wallet_rounded,
                title: "Budget Warnings",
                subtitle: "When you're close to budget limits",
                value: _budgetAlertsEnabled,
                onChanged: (value) => setState(() {
                  _budgetAlertsEnabled = value;
                  _updateNotificationSettings();
                }),
              ),

              // Reminder Alerts
              _buildNotificationCategoryCard(
                icon: Icons.calendar_today_rounded,
                title: "Daily Reminders",
                subtitle: "Remind me to log transactions",
                value: _reminderAlertsEnabled,
                onChanged: (value) => setState(() {
                  _reminderAlertsEnabled = value;
                  _updateNotificationSettings();
                }),
              ),

              // Insight Alerts
              _buildNotificationCategoryCard(
                icon: Icons.insights_rounded,
                title: "Weekly Insights",
                subtitle: "Financial trends & recommendations",
                value: _insightAlertsEnabled,
                onChanged: (value) => setState(() {
                  _insightAlertsEnabled = value;
                  _updateNotificationSettings();
                }),
              ),

              const SizedBox(height: 24),

              // Notification Examples
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "What You'll See",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Notifications will appear as beautiful dialogs and snackbars:",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      _buildExampleNotification(
                        "🚨 Spending Alert",
                        "You've spent ₱1,500 on Food this week - 50% above average",
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildExampleNotification(
                        "💰 Savings Update", 
                        "Great job! You've saved ₱2,000 of your ₱5,000 monthly goal",
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildExampleNotification(
                        "📊 Budget Warning",
                        "You've used 85% of your Transportation budget with 15 days left",
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildExampleNotification(
                        "📝 Daily Reminder",
                        "Don't forget to log your transactions for today!",
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildExampleNotification(
                        "📈 Weekly Insight",
                        "Your dining expenses decreased by 15% this week. Keep it up!",
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // How It Works
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "How In-App Notifications Work",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem("SnackBar Alerts", "Quick notifications at the bottom of the screen for spending alerts and reminders"),
                      _buildInfoItem("Dialog Insights", "Detailed financial insights appear as beautiful dialogs for important updates"),
                      _buildInfoItem("Real-time Updates", "Get notified immediately when unusual spending patterns are detected"),
                      _buildInfoItem("Smart Insights", "Receive personalized financial advice based on your spending habits"),
                      _buildInfoItem("Progress Tracking", "Stay updated on your savings goals and budget limits"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notification History (if you want to implement this later)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Notification History",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "All your notifications are stored and can be reviewed anytime.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showNotificationHistory();
                        },
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('View Notification History'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Disabled State Message
            if (!_notificationsEnabled) ...[
              const SizedBox(height: 40),
              Column(
                children: [
                  Icon(Icons.notifications_off_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "In-App Notifications are disabled",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Enable in-app notifications to get real-time spending alerts, savings updates, budget warnings, and personalized financial insights delivered as beautiful dialogs and snackbars within the app.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _notificationsEnabled = true;
                      });
                      _notificationService.toggleNotifications(true);
                      _updateNotificationSettings();
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Enable In-App Notifications'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildExampleNotification(String title, String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message, 
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationHistory() {
    final history = _notificationService.getNotificationHistory();
    
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No notification history yet')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification History'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.length,
              itemBuilder: (context, index) {
                final notification = history[history.length - 1 - index]; // Show latest first
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(notification['title'] ?? ''),
                    subtitle: Text(notification['message'] ?? ''),
                    trailing: Text(
                      _formatDate(notification['timestamp']),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Clear All'),
              onPressed: () {
                _notificationService.clearAllNotifications();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification history cleared')),
                );
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}