import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onlyfunds_v1/transaction_service.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';
import 'package:onlyfunds_v1/savings_service.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final SavingsService _savingsService = SavingsService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _goalFormKey = GlobalKey<FormState>();
  final _depositFormKey = GlobalKey<FormState>();

  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();

  String? _selectedCategory;

  // ------------------- UI Widgets -------------------

  Widget _displaySavings() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<double>(
                      stream: SavingsService().currentAmountSaved(), 
                      builder: (context, snapshot) { 
                        if (!snapshot.hasData) {
                          return const Text(
                            "₱0.00",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        double amountSaved = snapshot.data!; 
                        return Text(
                          NumberFormat.currency(locale: 'en_PH', symbol: "₱")
                              .format(amountSaved), // use amountSaved, not balance
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 4),
                    StreamBuilder<double>(
                      stream: SavingsService().currentTargetSavings(), 
                      builder: (context, snapshot) { 
                        if (!snapshot.hasData) {
                          return const Text(
                            "This month's Goal: ₱0.00",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey
                            ),
                          );
                        }

                        double targetSavings = snapshot.data!; 
                        return Text(
                          "This month's goal: ${NumberFormat.currency(locale: 'en_PH', symbol: "₱").format(targetSavings)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 90, 90, 90)
                          ),
                        );
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Colors.green, size: 32),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // allows specifying height
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => FractionallySizedBox(
                        heightFactor: 0.7, // take 75% of screen height
                        child: _depositSavingsForm()
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<double>(
              stream: SavingsService().currentAmountSaved(),
              builder: (context, snapshotSaved) {
                double saved = snapshotSaved.data ?? 0;

                return StreamBuilder<double>(
                  stream: SavingsService().currentTargetSavings(),
                  builder: (context, snapshotTarget) {
                    double target = snapshotTarget.data ?? 1; // avoid division by zero
                    double progress = (saved / target).clamp(0.0, 1.0);
                    double percentage = progress * 100;

                    return Stack(
                      alignment: Alignment.centerLeft, // centers the text inside the bar
                      children: [
                        
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            color: Colors.lightGreen,
                            minHeight: 20,
                          ),
                        ),

                        // 💬 Text on top of the progress bar
                        Text(
                          "  ${percentage.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12 // good contrast inside green bar
                          ),
                        ),
                      ],
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

  Widget _fundBox(String category, String amount, Color color) {
    return SizedBox(
      width: 180,
      height: 80,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(160, 0, 0, 0)),
            ),
            Text(
              amount,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(160, 0, 0, 0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fundBoxDynamic(String fundName, Color color) {
  return StreamBuilder<double>(
    stream: _savingsService.savedAmount(fundName),
    builder: (context, snapshot) {
      final amount = snapshot.data ?? 0.0;
      return _fundBox(
        fundName,
        NumberFormat.currency(locale: 'en_PH', symbol: "₱").format(amount),
        color,
      );
    },
  );
}

Widget _displayFundBox() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _fundBoxDynamic("Emergency Fund", const Color.fromARGB(255, 255, 60, 0)),
          _fundBoxDynamic("Travel Fund", const Color.fromARGB(255, 0, 247, 255)),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _fundBoxDynamic("School Fund", const Color.fromARGB(255, 255, 230, 0)),
          _fundBoxDynamic("Miscellaneous Fund", const Color.fromARGB(255, 0, 255, 85)),
        ],
      ),
    ],
  );
}

  Widget _goalSavingsForm() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _goalFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Create Savings Goal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: const [
                    DropdownMenuItem(
                        value: "Emergency Fund",
                        child: Text("Emergency Fund")),
                    DropdownMenuItem(
                        value: "Travel Fund", child: Text("Travel Fund")),
                    DropdownMenuItem(
                        value: "School Fund", child: Text("School Fund")),
                    DropdownMenuItem(
                        value: "Miscellaneous Fund", child: Text("Miscellaneous Fund")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Category is required";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: _goalAmountController,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    prefixText: "₱ ",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Amount is required";
                    }
                    if (double.tryParse(value) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Button(
                  text: "Set Goal",
                  onPressed: () async {
                    if (!_goalFormKey.currentState!.validate()) return;

                    await _savingsService.addSavingsGoal(
                      category: _selectedCategory ?? "Uncategorized",
                      amount: double.parse(_goalAmountController.text.trim()),
                    );

                    _scaffoldMessengerKey.currentState!.showSnackBar(
                      const SnackBar(content: Text("Savings Goal Created!")),
                    );

                    _goalAmountController.clear();
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _depositSavingsForm() {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _depositFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // wraps content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Available Balance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StreamBuilder<double>(
                  stream: TransactionService().currentMonthBalance(),
                  builder: (context, snapshot) {
                    final balance = snapshot.data ?? 0.0;
                    return Text(
                      NumberFormat.currency(locale: 'en_PH', symbol: "₱")
                          .format(balance),
                      style: const TextStyle(fontSize: 16.5),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Deposit to Savings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FutureBuilder<double>(
                  future: _savingsService.totalTarget().then((totalTarget) async {
                    final totalSaved = await _savingsService.totalSaved();
                    return totalTarget - totalSaved;
                  }),
                  builder: (context, snapshot) {
                    final remaining = snapshot.data ?? 0.0;
                    return Text(
                      "( ${NumberFormat.currency(locale: 'en_PH', symbol: "₱").format(remaining)} left to reach target )",
                      style: TextStyle(
                        fontSize: 14, // smaller
                        color: Colors.grey[600], // grey
                        fontWeight: FontWeight.normal, // not bold
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextFormField(
                  controller: _depositAmountController,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    prefixText: "₱ ",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Amount is required";
                    }
                    if (double.tryParse(value) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Builder(builder: (context) {
                  return Button(
                    text: "Deposit",
                    onPressed: () async {
                      if (!_depositFormKey.currentState!.validate()) return;

                      final depositAmount =
                          double.tryParse(_depositAmountController.text.trim());
                      if (depositAmount == null) return;

                      // Get current balance
                      final balanceSnapshot =
                          await TransactionService().currentMonthBalance().first;
                      final availableBalance = balanceSnapshot;

                      if (depositAmount > availableBalance) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Deposit exceeds available balance (₱${availableBalance.toStringAsFixed(2)})"),
                          ),
                        );
                        return;
                      }

                      // Get total target and already saved amount
                      final totalTarget = await _savingsService.totalTarget();
                      final totalSaved = await _savingsService.totalSaved();
                      final remaining = totalTarget - totalSaved;

                      if (depositAmount > remaining) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Deposit exceeds remaining goal (₱${remaining.toStringAsFixed(2)})"),
                          ),
                        );
                        return;
                      }

                      // Deduct from balance
                      await TransactionService().deductFromBalance(
                        amount: double.tryParse(_depositAmountController.text) ?? 0.0,
                      );

                      // Update saved amount
                      await _savingsService.updateAmountSaved(depositAmount);

                      _depositAmountController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Deposit successful!")),
                      );

                      setState(() {}); // refresh remaining amount
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}




  // ------------------- Build -------------------

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _displaySavings(),
                const SizedBox(height: 6),
                _displayFundBox(),
                const SizedBox(height: 6),
                _goalSavingsForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
