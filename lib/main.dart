import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'calibration_screen.dart';

void main() {
  runApp(const AlcotestApp());
}

class AlcotestApp extends StatelessWidget {
  const AlcotestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alcotest',
      debugShowCheckedModeBanner: false,
      home: const CalibrationScreen(),
    );
  }
}