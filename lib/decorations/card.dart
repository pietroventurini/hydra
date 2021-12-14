import 'package:flutter/material.dart';

final BoxDecoration cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(24)),
  boxShadow: [
      BoxShadow(
      color: Colors.grey.withOpacity(.23),
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ],
);