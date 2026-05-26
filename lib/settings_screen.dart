import 'package:flutter/material.dart';

class UserSettings {
  static bool isMale = false;
  static bool isPro = false;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isMale = UserSettings.isMale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {
              UserSettings.isMale = _isMale;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SettingsScreen2()),
              );
            },
            child: const Text('Next',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select gender',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Affects BAC calculation (Widmark formula)',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 32),
            Row(
              children: [
                _genderButton('Female', false),
                const SizedBox(width: 16),
                _genderButton('Male', true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderButton(String label, bool male) {
    final selected = _isMale == male;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isMale = male),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? Colors.black : Colors.grey,
                width: 2),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen2 extends StatefulWidget {
  const SettingsScreen2({super.key});

  @override
  State<SettingsScreen2> createState() => _SettingsScreen2State();
}

class _SettingsScreen2State extends State<SettingsScreen2> {
  bool _isPro = UserSettings.isPro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () {
              UserSettings.isPro = _isPro;
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Driver type',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Professional drivers have a 0.0‰ legal limit',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 32),
            Row(
              children: [
                _driverButton('Just\nDriver', false),
                const SizedBox(width: 16),
                _driverButton('Professional\nDriver', true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _driverButton(String label, bool pro) {
    final selected = _isPro == pro;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isPro = pro),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? Colors.black : Colors.grey,
                width: 2),
          ),
          child: Center(
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}