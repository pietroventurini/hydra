import 'package:flutter/material.dart';

BoxDecoration getCardDecoration({
  Color color = Colors.white,
  Gradient? gradient 
  }) {
    return BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: BorderRadius.all(Radius.circular(24)),
      boxShadow: [
          BoxShadow(
          color: Colors.grey.withOpacity(.15),
          blurRadius: 30,
          offset: Offset(0, 5),
        ),
      ],
    );
}

final Gradient whiteLinearGradient = const LinearGradient(
    colors: [const Color.fromARGB(255, 252, 253, 255), const Color.fromARGB(255, 244, 249, 253)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

final Gradient redLinearGradient = const LinearGradient(
    colors: [const Color.fromARGB(255, 214, 0, 0), Colors.red],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

final BoxDecoration cardDecoration = BoxDecoration(
  color: Colors.white,
  gradient: LinearGradient(
    colors: [const Color.fromARGB(255, 162, 251, 254), const Color.fromARGB(255, 56, 225, 237)],//[Colors.lightBlue.shade200, Colors.lightBlue.shade100],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.all(Radius.circular(24)),
  boxShadow: [
      BoxShadow(
      color: Colors.grey.withOpacity(.23),
      blurRadius: 30,
      offset: Offset(0, 10),
      
    ),
  ],
);