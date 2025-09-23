import 'package:flutter/material.dart';
import 'package:onlyfunds_v1/pages/settings_page.dart';
import 'package:onlyfunds_v1/pages/history_page.dart';
import 'package:onlyfunds_v1/pages/reports_page.dart';
import 'package:onlyfunds_v1/pages/savings_page.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';
import 'package:onlyfunds_v1/transaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Home Page for appbar and bottom nav
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Home is center

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Savings
      Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomAppBar(
          title: "Savings",
          showBack: true,
          onBack: () => setState(() => _selectedIndex = 2),
        ),
        body: const SavingsPage(),
      ),

      // Reports
      Scaffold(
        appBar: CustomAppBar(
          title: "Reports",
          showBack: true,
          onBack: () => setState(() => _selectedIndex = 2),
        ),
        body: const ReportsPage(),
      ),

      // Home (black app bar, no back button)
      const HomePageContent(),

      // History
      Scaffold(
        appBar: CustomAppBar(
          title: "Transaction History",
          showBack: true,
          onBack: () => setState(() => _selectedIndex = 2),
        ),
        body: const HistoryPage(),
      ),

      // Settings
      Scaffold(
        appBar: CustomAppBar(
          title: "Settings",
          showBack: true,
          onBack: () => setState(() => _selectedIndex = 2),
        ),
        body: const SettingsPage(),
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Savings"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

/// Home Page Content (Original na ginawa mo)
class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final TransactionService _transactionService = TransactionService();
  String? _selectedCategory;

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Budget Tracker",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                children: const [
                  Text("Remaining Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 8),
                  Text("₱2,450.00",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Income and Expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text("+₱2,450.00 Income",
                    style: TextStyle(color: Colors.green, fontSize: 16)),
                Text("-₱450.00 Expenses",
                    style: TextStyle(color: Colors.red, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 16),

            // Add Transaction Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Add Transaction",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            // Label + Category Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(labelText: "Label"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Income/Allowance", child: Text("Income/Allowance")),
                        DropdownMenuItem(value: "Utility Bills", child: Text("Utility Bills")),
                        DropdownMenuItem(value: "Transportation", child: Text("Transportation")),
                        DropdownMenuItem(value: "Food/Grocery", child: Text("Food/Grocery")),
                        DropdownMenuItem(value: "Subscriptions", child: Text("Subscriptions")),
                        DropdownMenuItem(value: "Savings", child: Text("Savings")),
                        DropdownMenuItem(value: "Shopping/Other", child: Text("Shopping/Other")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ),
            const SizedBox(height: 10),

            // Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Button(
                      text: "+ Income",
                      onPressed: () async {
                        await _transactionService.addTransaction(
                          label: _labelController.text.trim(),
                          category: _selectedCategory ?? "Uncategorized",
                          description: _descriptionController.text.trim().isEmpty
                              ? null
                              : _descriptionController.text.trim(),
                          amount: double.tryParse(_amountController.text.trim()) ?? 0,
                          type: "income",
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Income Added!")),
                        );

                        _labelController.clear();
                        _descriptionController.clear();
                        _amountController.clear();
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Button(
                      text: "- Expense",
                      textColor: Colors.black,
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        await _transactionService.addTransaction(
                          label: _labelController.text.trim(),
                          category: _selectedCategory ?? "Uncategorized",
                          description: _descriptionController.text.trim().isEmpty
                              ? null
                              : _descriptionController.text.trim(),
                          amount: double.tryParse(_amountController.text.trim()) ?? 0,
                          type: "expense",
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Expense Added!")),
                        );

                        _labelController.clear();
                        _descriptionController.clear();
                        _amountController.clear();
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recent Transactions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Recent Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            StreamBuilder(
              stream: _transactionService.getUserTransactions(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                  return const Center(child: Text("No transactions yet"));
                }

                final transactions = snapshot.data.docs.take(5).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final doc = transactions[index];
                    final data = doc.data() as Map<String, dynamic>;

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
          ],
        ),
      ),
  
    );
  }
}
