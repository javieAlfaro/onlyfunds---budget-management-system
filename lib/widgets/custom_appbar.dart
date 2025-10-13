import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool? showNotificationsIcon; 
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.showNotificationsIcon, // Remove default value
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bool showIcon = showNotificationsIcon ?? true; // Provide default here
    
    return AppBar(
      backgroundColor: Colors.grey[100],
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
              onPressed: onBack ?? () {
                Navigator.of(context).maybePop();
              },
            )
          : null,
      actions: [
        if (showIcon) // Use the local variable with default
          IconButton(
            icon: CircleAvatar(
              child: Icon(Icons.person),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/account');
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}