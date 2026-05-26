import 'package:flutter/material.dart';
// RPi server address
const String rpiUrl = 'http://192.168.0.29:5000/bac';

// Background logo widget
Widget backgroundLogo() {
  return Positioned.fill(
    child: Opacity(
      opacity: 0.2,
      child: Image.asset(
        'assets/images/alcotesterLogo.png',
        fit: BoxFit.contain,
      ),
    ),
  );
}