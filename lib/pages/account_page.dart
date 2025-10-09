import 'package:flutter/material.dart';
import 'package:onlyfunds_v1/pages/settings_page.dart';
import 'package:onlyfunds_v1/widgets/custom_appbar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Account Information",
        showBack: true,
        showNotificationsIcon: false,
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: const Placeholder(),
    );
  }
}