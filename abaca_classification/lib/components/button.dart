import 'package:flutter/material.dart';
import 'package:abaca_classification/theme/styles.dart';

class GradientButtonFb1 extends StatelessWidget {
  final String text;
  final Function() onPressed;

  const GradientButtonFb1({
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(colors: [Colors.white, Colors.white]),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          alignment: Alignment.center,
          padding: MaterialStateProperty.all(
              const EdgeInsets.only(right: 35, left: 35, top: 15, bottom: 15)),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius)),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
              color: text2Color, fontWeight: fontSM, fontSize: textSM),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const MyButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientButtonFb1(
      onPressed: onPressed,
      text: text,
    );
  }
}
