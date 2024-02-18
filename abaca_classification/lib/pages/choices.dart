import 'package:flutter/material.dart';
import 'package:abaca_classification/pages/camera.dart';
import 'package:abaca_classification/theme/styles.dart';
import 'package:abaca_classification/components/iconbutton.dart';

class MyChoices extends StatefulWidget {
  const MyChoices({Key? key}) : super(key: key);

  @override
  State<MyChoices> createState() => _MyChoicesState();
}

class _MyChoicesState extends State<MyChoices> {
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
              ),
              MyIconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyCamera(),
                    ),
                  );
                },
                icon: Icons.camera,
              ),
              const SizedBox(height: sizedBoxLG),
              MyIconButton(
                onPressed: () {},
                icon: Icons.print,
              ),
              const SizedBox(height: sizedBoxLG),
              MyIconButton(
                onPressed: () {},
                icon: Icons.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
