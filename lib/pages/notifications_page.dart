import 'package:flutter/material.dart';
import 'package:onlyfunds_v1/widgets/custom_appbar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Notifications",
        showBack: true,
        showNotificationsIcon: false,
        onBack: () {
          Navigator.of(context).pop();
        },    
      ),
      body: const Placeholder()
    );
  }
}