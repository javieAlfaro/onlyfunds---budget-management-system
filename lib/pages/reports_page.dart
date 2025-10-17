// pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyfunds_v1/ml_analytics_service.dart';

class ReportsPage extends StatefulWidget {
  final VoidCallback? onBack;

  const ReportsPage({
    super.key,
    this.onBack,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Map<String, dynamic>? _insights;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final insights = await _analyticsService.getFinancialInsights(user.uid);
        setState(() {
          _insights = insights;
        });
      }
    } catch (e) {
      print('Error loading insights: $e');
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadInsights,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text(
                'Financial Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.grey[100],
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: _loadInsights,
                ),
              ],
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasError)
              SliverFillRemaining(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load insights',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadInsights,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (_insights == null)
              const SliverFillRemaining(
                child: Center(child: Text('No data available')),
              )
            else
              _buildInsightsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsContent() {
  // SAFE ACCESS: Use as Map<String, dynamic>? and null checks
  final basicMetrics = (_insights?['basicMetrics'] as Map<String, dynamic>?) ?? {};
  final predictions = (_insights?['predictions'] as Map<String, dynamic>?) ?? {};
  final recommendations = (_insights?['recommendations'] as Map<String, dynamic>?) ?? {};
  final alerts = (_insights?['alerts'] as List<dynamic>?) ?? [];
  final categoryBreakdown = (_insights?['categoryBreakdown'] as Map<String, dynamic>?) ?? {};
  final savingsAnalysis = (_insights?['savingsAnalysis'] as Map<String, dynamic>?) ?? {};

  return SliverList(
    delegate: SliverChildListDelegate([
      if (alerts.isNotEmpty) _buildAlertsSection(alerts),
      _buildFinancialSummary(basicMetrics),
      _buildPredictionsSection(predictions),
      _buildCategoryBreakdown(categoryBreakdown),
      _buildSavingsAnalysis(savingsAnalysis, basicMetrics),
      _buildRecommendationsSection(recommendations),
      const SizedBox(height: 20),
    ]),
  );
}

  Widget _buildAlertsSection(List<dynamic> alerts) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ Financial Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...alerts.map((alert) {
            final Map<String, dynamic> alertData = alert;
            return Card(
              color: _getAlertColor(alertData['severity']),
              child: ListTile(
                leading: Icon(_getAlertIcon(alertData['type']), color: Colors.white),
                title: Text(
                  alertData['message'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                subtitle: alertData['amount'] != null 
                    ? Text(
                        'Amount: ₱${alertData['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70),
                      )
                    : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(Map<String, dynamic> metrics) {
    final totalIncome = metrics['totalIncome'] ?? 0.0;
    final totalExpenses = metrics['totalExpenses'] ?? 0.0;
    final savings = metrics['savings'] ?? 0.0;
    final savingsRate = metrics['savingsRate'] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricTile('Income', totalIncome, Colors.green),
                  _buildMetricTile('Expenses', totalExpenses, Colors.red),
                  _buildMetricTile('Savings', savings, savings >= 0 ? Colors.blue : Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: totalIncome > 0 ? (savings / totalIncome).clamp(0.0, 1.0) : 0.0,
                backgroundColor: Colors.grey[300],
                color: savings >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                'Savings Rate: ${savingsRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: savingsRate >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionsSection(Map<String, dynamic> predictions) {
    final predictedAmount = predictions['predictedAmount'];
    final confidence = predictions['confidence'] ?? 0.0;
    final trend = predictions['trend'] ?? 'stable';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📈 Next Month Prediction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (predictedAmount != null)
                Column(
                  children: [
                    Text(
                      'Predicted Expenses: ₱${predictedAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: confidence,
                      backgroundColor: Colors.grey[300],
                      color: _getConfidenceColor(confidence),
                    ),
                    Text(
                      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trend: ${trend.toString().toUpperCase()}',
                      style: TextStyle(
                        color: _getTrendColor(trend),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  predictions['message'] ?? 'Need more data for predictions',
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // SIMPLIFIED CATEGORY BREAKDOWN - No external chart library
  Widget _buildCategoryBreakdown(Map<String, dynamic> categoryBreakdown) {
    final sortedCategories = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final totalAmount = sortedCategories.fold(0.0, (sum, item) => sum + item.value);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spending by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...sortedCategories.map((entry) {
                final percentage = totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0;
                return _buildCategoryProgressRow(
                  entry.key,
                  entry.value,
                  percentage,
                  _getCategoryColor(entry.key),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryProgressRow(String category, double amount, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '₱${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsAnalysis(Map<String, dynamic> savingsAnalysis, Map<String, dynamic> metrics) {
    final profile = savingsAnalysis['savingsProfile'] ?? 'New User';
    final savingsRate = savingsAnalysis['savingsRate'] ?? 0.0;
    final recommendedTarget = savingsAnalysis['recommendedTarget'] ?? 0.0;
    final currentSavings = metrics['savings'] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💰 Savings Analysis - (20% Default Goal)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getProfileColor(profile),
                  child: Text(
                    profile[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  profile,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Savings Rate: ${savingsRate.toStringAsFixed(1)}%'),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: recommendedTarget > 0 ? (currentSavings / recommendedTarget).clamp(0.0, 1.0) : 0.0,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: ₱${currentSavings.toStringAsFixed(2)} / ₱${recommendedTarget.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(Map<String, dynamic> recommendations) {
    final categoryRecos = recommendations['categoryRecommendations'] as Map<String, dynamic>? ?? {};
    final overallAdvice = recommendations['overallAdvice'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡 Personalized Recommendations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              if (overallAdvice.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    overallAdvice,
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),

              ...categoryRecos.entries.map((entry) {
                final category = entry.key;
                final data = entry.value as Map<String, dynamic>;
                final potentialSavings = data['potentialSavings'] ?? 0.0;

                if (potentialSavings <= 0) return const SizedBox.shrink();

                return ListTile(
                  leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  title: Text(category),
                  subtitle: Text(data['advice'] ?? ''),
                  trailing: Text(
                    'Save ₱${potentialSavings.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),

              if (categoryRecos.isEmpty)
                const Text(
                  'Add more transactions to get personalized recommendations',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildMetricTile(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper Methods for Styling
  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'spending_spike': return Icons.trending_up;
      case 'savings_alert': return Icons.savings;
      case 'income_drop': return Icons.arrow_downward;
      default: return Icons.notifications;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.7) return Colors.green;
    if (confidence > 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'increasing': return Colors.red;
      case 'decreasing': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getProfileColor(String profile) {
    switch (profile) {
      case 'Super Saver': return Colors.green;
      case 'Good Saver': return Colors.lightGreen;
      case 'Moderate Saver': return Colors.blue;
      case 'Minimal Saver': return Colors.orange;
      case 'Over Spender': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.deepOrange,
    ];
    
    final index = category.hashCode % colors.length;
    return colors[index];
  }
}