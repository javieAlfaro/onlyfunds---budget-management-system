import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity, 
    this.backgroundColor = const Color.fromARGB(255, 0, 0, 0), 
    this.textColor = Colors.white, 
    this.borderColor = const Color.fromARGB(255, 0, 0, 0), 
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: borderColor, width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }
}