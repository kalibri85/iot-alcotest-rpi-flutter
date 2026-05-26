import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'settings_screen.dart';
import 'constants.dart';
import 'result_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int _countdown = 30;
  Timer? _timer;
  List<double> _readings = [];
  double _baseline = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startCalibration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startCalibration() {
    setState(() {
      _countdown = 30;
      _readings = [];
      _hasError = false;
      _errorMessage = '';
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final response = await http
            .get(Uri.parse(rpiUrl))
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final voltage = (data['voltage'] as num).toDouble();

          if (voltage >= 3.0) {
            timer.cancel();
            setState(() {
              _hasError = true;
              _errorMessage =
              'Sensor value too high.\nPlease ensure clean air\naround the sensor and try again.';
            });
            return;
          }
          _readings.add(voltage);
        }
      } catch (_) {}

      setState(() => _countdown--);

      if (_countdown <= 0) {
        timer.cancel();
        await _audioPlayer.play(AssetSource('sounds/READY.mp3'));
        if (_readings.isNotEmpty) {
          _baseline = _readings.reduce((a, b) => a + b) / _readings.length;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(baseline: _baseline),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          backgroundLogo(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gear icon
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      icon: const Icon(Icons.settings,
                          color: Colors.black, size: 28),
                      onPressed: () async {
                        _timer?.cancel();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SettingsScreen()),
                        );
                        _startCalibration();
                      },
                    ),
                  ),
                ),

                if (_hasError) ...[
                  const Spacer(),
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _startCalibration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Try Again'),
                  ),
                  const Spacer(),
                ] else ...[
                  // Text at the top
                  const SizedBox(height: 16),
                  const Text(
                    'Calibration',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                              blurRadius: 8,
                              color: Colors.white,
                              offset: Offset(0, 0))
                        ]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please ensure clean air around sensor',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  // Timer in the center
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: (30 - _countdown) / 30,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '$_countdown',
                        style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Text at the bottom
                  const Text(
                    'Reading baseline...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}