import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:abaca_classification/firebase_options.dart';
import 'package:abaca_classification/theme/styles.dart'; // Ensure this file defines gradient1Color and gradient2Color
import 'package:abaca_classification/pages/home.dart'; // Ensure this file and the HomePage widget are correctly defined

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                gradient1Color,
                gradient2Color,
              ],
            ),
          ),
          child:
              const HomePage(), // Ensure HomePage is a widget that can be displayed on its own.
        ),
      ),
    );
  }
}
