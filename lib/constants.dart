import 'package:flutter/material.dart';
// RPi server address
const String rpiUrl = 'http://192.168.0.29:5000/bac';

// Sound files
const String soundReady = 'sounds/READY.mp3';
const String soundRed = 'sounds/RED.mp3';
const String soundError = 'sounds/ERROR.mp3';

// Background logo widget
Widget backgroundLogo() {
  return Positioned.fill(
    child: Opacity(
      opacity: 0.15,
      child: Image.asset(
        'assets/images/alcotesterLogo.png',
        fit: BoxFit.contain,
      ),
    ),
  );
}