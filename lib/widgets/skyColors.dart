import 'package:flutter/material.dart';

class SkyColors {
  static final Gradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(57, 2, 63, 1),
      Color.fromRGBO(96, 18, 82, 1),
      Color.fromRGBO(125, 46, 86, 1),
      Color.fromRGBO(187, 135, 84, 1)
    ],
  );

  static BoxDecoration skyDecoration = BoxDecoration(
    gradient: skyGradient,
  );
}
