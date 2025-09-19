import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final double amount;
  final String type; 
  final String category; 

  const TransactionCard({
    Key? key,
    required this.label,
    required this.date,
    required this.amount,
    required this.type,
    required this.category, 
  }) : super(key: key);


  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "income/allowance":
        return Icons.attach_money; 
      case "utility bills":
        return Icons.lightbulb_outline; 
      case "transportation":
        return Icons.directions_bus;
      case "food/grocery":
        return Icons.restaurant;
      case "subscriptions":
        return Icons.subscriptions; 
      case "savings":
        return Icons.savings; 
      case "shopping/other":
        return Icons.shopping_bag; 
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "";
    if (date != null) {
      final now = DateTime.now();
      final difference = now.difference(date!).inDays;

      if (difference == 0) {
        formattedDate = "Today";
      } else if (difference == 1) {
        formattedDate = "Yesterday";
      } else {
        formattedDate = "$difference days ago";
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          _getCategoryIcon(category),
          color: type == "income" ? Colors.green : Colors.red,
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(formattedDate),
        trailing: Text(
          (type == "income" ? "+₱" : "-₱") + amount.toStringAsFixed(2),
          style: TextStyle(
            color: type == "income" ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
