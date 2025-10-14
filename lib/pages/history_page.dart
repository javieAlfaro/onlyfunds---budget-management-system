import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onlyfunds_v1/transaction_service.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = "newest";
  final TransactionService _transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text("Newest"),
                  selected: selectedFilter == "newest",
                  onSelected: (_) {
                    setState(() {
                      selectedFilter = "newest";
                    });
                  },
                ),
                FilterChip(
                  label: const Text("Oldest"),
                  selected: selectedFilter == "oldest",
                  onSelected: (_) {
                    setState(() {
                      selectedFilter = "oldest";
                    });
                  },
                ),
                FilterChip(
                  label: const Text("Income"),
                  selected: selectedFilter == "income",
                  onSelected: (_) {
                    setState(() {
                      selectedFilter = "income";
                    });
                  },
                ),
                FilterChip(
                  label: const Text("Expense"),
                  selected: selectedFilter == "expense",
                  onSelected: (_) {
                    setState(() {
                      selectedFilter = "expense";
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transactions list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _transactionService.getUserTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No transactions yet"));
                  }

                  final allTransactions = snapshot.data!.docs;

                  List<QueryDocumentSnapshot> filteredTransactions;

                  if (selectedFilter == "income" || selectedFilter == "expense") {
                    filteredTransactions = allTransactions.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data["type"] == selectedFilter;
                    }).toList();
                  } else {
                    filteredTransactions = List.from(allTransactions);
                  }
                  
                  filteredTransactions.sort((a, b) {
                    final aDate =
                        (a['date_added'] as Timestamp?)?.toDate() ?? DateTime(0);
                    final bDate =
                        (b['date_added'] as Timestamp?)?.toDate() ?? DateTime(0);

                    // "Newest" = descending, "Oldest" = ascending
                    if (selectedFilter == "oldest") {
                      return aDate.compareTo(bDate);
                    } else {
                      return bDate.compareTo(aDate);
                    }
                  });

                  if (filteredTransactions.isEmpty) {
                    return const Center(child: Text("No matching transactions"));
                  }

                  return ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final data =
                          filteredTransactions[index].data() as Map<String, dynamic>;

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