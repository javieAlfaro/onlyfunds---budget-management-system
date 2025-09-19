import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlyfunds_v1/transaction_service.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final TransactionService _transactionService = TransactionService();

  int _selectedIndex = 2; // Home is in the center
  String? _selectedCategory;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          style: TextStyle(color: Colors.white), // ✅ White title text
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
            // ✅ Full-width Balance Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
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
            Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
            const SizedBox(height: 16),

            // Add Transaction Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Add Transaction",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            // Label + Dropdown Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _labelController,
                      decoration: InputDecoration(labelText: "Label"),
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

      
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
            ),
            const SizedBox(height: 10),

    
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Button(
                      text: "+ Income",
                      onPressed: () async{
                        await TransactionService().addTransaction(
                          label: _labelController.text.trim(),
                          category: _selectedCategory ?? "Uncategorized",
                          description: _descriptionController.text.trim().isEmpty
                            ? null
                            :_descriptionController.text.trim(),
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
                        await TransactionService().addTransaction(
                          label: _labelController.text.trim(),
                          category: _selectedCategory ?? "Uncategorized",
                          description: _descriptionController.text.trim().isEmpty
                            ? null
                            : _descriptionController.text.trim(), 
                          amount: double.tryParse(_amountController.text.trim()) ?? 0, 
                          type: "expense"
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Expense Added!"))
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
                  return const Center(child: CircularProgressIndicator(),);
                }
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                  return const Center(child: Text("No transactions yet"),);
                }

                final transactions = snapshot.data.docs.take(5).toList();

                return ListView.builder(
                  shrinkWrap: true,
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
                  });
              })
          ],
        ),
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

  Widget _buildTransaction(String title, String subtitle, String amount, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.category, color: Colors.black),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(amount,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
