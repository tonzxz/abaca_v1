import 'package:flutter/material.dart';
import 'package:abaca_classification/pages/home.dart';
import 'package:abaca_classification/theme/themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: lightMode.copyWith(
        colorScheme: lightMode.colorScheme.copyWith(
          background: const Color(0xfffabd04),
        ),
      ),
    );
  }
}
