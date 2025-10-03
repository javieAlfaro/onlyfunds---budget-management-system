import 'package:flutter/material.dart';
import 'package:onlyfunds_v1/widgets/widgets.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  Widget _displaySavings() {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: 
      Padding(padding: EdgeInsets.all(16),
      child: Column(
          children: [
            Text("₱5,450.00", 
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("This month's Goal: ₱6,000.00",
                  style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 5450 / 6000, // Edit later
              backgroundColor: Colors.grey[260],
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(8),
              minHeight: 16,
            )
          ],
        ),
      )
    );
  }

Widget _fundBox(String category, String amount, Color color) {
  return SizedBox(
    width: 180,
    height: 80,
    child: Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(category, style: TextStyle(fontWeight: FontWeight.bold, color: const Color.fromARGB(160, 0, 0, 0)),),
          Text(amount, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: const Color.fromARGB(160, 0, 0, 0)),),
        ],
      ),
    ),
  );
}

Widget _displayFundBox() {
  return Column(
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _fundBox("Emergencey Fund", "₱2,000.00", const Color.fromARGB(255, 255, 60, 0)),
        _fundBox("Travel Fund", "₱1,000.00", const Color.fromARGB(255, 0, 247, 255)),
      ],
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _fundBox("School Fund", "₱2,500.00", const Color.fromARGB(255, 255, 230, 0)),
        _fundBox("Miscellaneous Fund", "₱500.00", const Color.fromARGB(255, 0, 255, 85)),
      ],
      )
    ],
  );
}

Widget _savingsForm() {
  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text("Add Savings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        ),
        const SizedBox(height: 16),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: "Category",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: "Emergency Fund",
                child: Text("Emergency Fund"),),
              DropdownMenuItem(
                value: "Travel Fund",
                child: Text("Travel Fund")),
              DropdownMenuItem(
                value: "School Fund",
                child: Text("School Fund")),
              DropdownMenuItem(
                value: "Miscellaneous",
                child: Text("Miscellaneous")),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            }
          )
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Amount is Required";
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
            text: "Add to Savings", 
            onPressed: () {}),
        ),
      ],
    )
  );
}

final _formKey = GlobalKey<FormState>();
String? _selectedCategory;
final TextEditingController _amountController = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: Colors.grey[100],
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _displaySavings(),
            const SizedBox(height: 16),
            _displayFundBox(),
            const SizedBox(height: 16),
            _savingsForm(),
          ],
        ),
      ),
    ),
  );
}
}