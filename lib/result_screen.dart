import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'settings_screen.dart';
import 'constants.dart';
import 'calibration_screen.dart';

class ResultScreen extends StatefulWidget {
  final double baseline;

  const ResultScreen({super.key, required this.baseline});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  double _bac = 0.0;
  double _voltage = 0.0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _takeMeasurement();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _takeMeasurement() async {
    // Give the user 3 seconds to start blowing
    await Future.delayed(const Duration(seconds: 3));
    try {
      final response = await http
          .get(Uri.parse(rpiUrl))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _voltage = (data['voltage'] as num).toDouble();
        _bac = _voltageToBac(_voltage);
        setState(() => _isLoading = false);

        // Play sound based on result
        if (_bac > _limit && _hoursToSober > 4) {
          await _audioPlayer.play(AssetSource(soundRed));
        }
      }
    } catch (_) {
      await _audioPlayer.play(AssetSource(soundError));
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Cannot connect to device.\nCheck WiFi connection.';
      });
    }
  }

  // Logic for converting voltage to promile
  double _voltageToBac(double voltage) {
    if (voltage < widget.baseline + 0.15) return 0.0;
    final ratio = (voltage - widget.baseline) / (3.8 - widget.baseline);
    double bac = ratio * 2.0;
    // Widmark gender adjustment
    if (UserSettings.isMale) bac = bac * 0.55 / 0.68;
    return double.parse(bac.toStringAsFixed(3));
  }

  // Limit depending on driver type
  double get _limit => UserSettings.isPro ? 0.0 : 0.4;

  // Time to sobriety
  double get _hoursToSober {
    if (_bac <= _limit) return 0;
    return (_bac - _limit) / 0.15;
  }

  // Color depending on result
  Color get _statusColor {
    if (_bac <= _limit) return Colors.green;
    if (_hoursToSober <= 4) return Colors.orange;
    return Colors.red;
  }

  String get _statusTitle {
    if (_bac <= _limit) return 'You can drive';
    if (_hoursToSober <= 4) return 'Do not drive yet';
    return 'Do not drive today';
  }

  String get _statusAdvice {
    if (_bac <= _limit) {
      return 'Your BAC is within the legal limit.\nDrive safely!';
    }
    if (_hoursToSober <= 4) {
      return 'Stop drinking. Drink water.\nHave a coffee. Take a walk.\nWait ${_hoursToSober.toStringAsFixed(1)} hours, then retest.';
    }
    return 'Your BAC is too high.\nCall a taxi or use a\ndesignated driver service.\n(${_hoursToSober.toStringAsFixed(1)} hours to sober up)';
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
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SettingsScreen()),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(),

                // 3 states of screen
                if (_hasError) ...[
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 80),
                  const SizedBox(height: 24),
                  Text(_errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CalibrationScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Try Again'),
                  ),
                ] else if (_isLoading) ...[
                  const Text('Blow into the sensor',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Keep sensor 2 cm away',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: Colors.black),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: _statusColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _bac.toStringAsFixed(3),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text('‰  BAC',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 20)),
                          const SizedBox(height: 20),
                          Text(_statusTitle,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(_statusAdvice,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CalibrationScreen()),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.black54),
                    label: const Text('Test again',
                        style: TextStyle(
                            color: Colors.black54, fontSize: 16)),
                  ),
                ],

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}