import 'package:flutter/material.dart';
import 'package:abaca_classification/theme/styles.dart';
import 'package:abaca_classification/pages/choices.dart';
import 'package:abaca_classification/components/button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                Image.asset(
                  "assets/images/abacalogo.png",
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: sizedBoxLG),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'ABACA GRADE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: textMD,
                          fontWeight: fontLG,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'CLASSIFICATION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: textLG,
                          fontWeight: fontXL,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: sizedBoxLG),
                const SizedBox(height: sizedBoxLG),
                const SizedBox(height: sizedBoxLG),
                const SizedBox(height: sizedBoxLG),
                MyButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MyChoices(),
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
