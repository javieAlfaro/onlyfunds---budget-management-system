import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyfunds_v1/transaction_service.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';

class HistoryPage extends StatelessWidget {
  final VoidCallback? onBack;

  const HistoryPage({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionService _transactionService = TransactionService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tabs (All, Income, Expenses, Date)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text("All"),
                  selected: true,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text("Income"),
                  selected: false,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text("Expenses"),
                  selected: false,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text("Date"),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transactions List
            Expanded(
              child: StreamBuilder(
                stream: _transactionService.getUserTransactions(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No transactions yet"));
                  }

                  final transactions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final data =
                          transactions[index].data() as Map<String, dynamic>;

                      return TransactionCard(
                        label: data["label"] ?? "",
                        date: (data["date_added"] as Timestamp?)?.toDate(),
                        amount: (data["amount"] ?? 0).toDouble(),
                        type: data["type"] ?? "expense",
                        category: data["category"] ?? "Uncategorized",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
