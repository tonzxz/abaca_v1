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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'ABACA GRADES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: textMD,
                        fontWeight: fontLG,
                        color: text2Color,
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
                        color: text2Color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: sizedBoxLG),
              const SizedBox(height: sizedBoxLG),
              const SizedBox(height: sizedBoxLG),
              Image.asset(
                "assets/images/abacalogo.png",
                width: 250,
                height: 250,
              ),
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
    );
  }
}
