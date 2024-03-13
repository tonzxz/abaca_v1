import 'package:flutter/material.dart';
import 'package:abaca_classification/pages/camera.dart';
import 'package:abaca_classification/theme/styles.dart';
import 'package:abaca_classification/components/button.dart';

class MyLandingPage extends StatefulWidget {
  const MyLandingPage({super.key});

  @override
  State<MyLandingPage> createState() => _MyLandingPageState();
}

class _MyLandingPageState extends State<MyLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                MyButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MyCamera(),
                      ),
                    );
                  },
                  text: 'Get Started',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
