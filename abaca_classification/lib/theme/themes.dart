import "package:flutter/material.dart";

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Color(0xfffabd04),
    primary: Color.fromARGB(255, 0, 0, 0),
    secondary: Color(0xFF0099cb),
    tertiary: Color(0xFFfe8926),
    surface: Colors.white,
  ),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.grey[800],
        displayColor: Colors.black,
      ),
);
