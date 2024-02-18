import 'package:flutter/material.dart';
import 'package:abaca_classification/theme/styles.dart';

class MyIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const MyIconButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Adjust the height as needed
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 60),
          color: mainColor, // Icon color
        ),
      ),
    );
  }
}
