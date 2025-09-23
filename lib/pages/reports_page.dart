import 'package:flutter/material.dart';


class ReportsPage extends StatelessWidget {
  final VoidCallback? onBack;

  const ReportsPage({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(),
      ),
    );
  }
}
