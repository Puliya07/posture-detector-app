import 'package:flutter/material.dart';
import '../models/alert_settings.dart';

class SettingsScreen extends StatefulWidget {
  final Function(AlertSettings) onSettingsChanged;
  final AlertSettings initialSettings;

  const SettingsScreen({
    Key? key,
    required this.onSettingsChanged,
    required this.initialSettings,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _angleThreshold;
  late bool _enableSound;
  late bool _enableVibration;

  @override
  void initState() {
    super.initState();
    _angleThreshold = widget.initialSettings.angleThreshold;
    _enableSound = widget.initialSettings.enableSound;
    _enableVibration = widget.initialSettings.enableVibration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alert Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Posture Angle Threshold: ${_angleThreshold.toStringAsFixed(1)}°"),
              subtitle: Slider(
                value: _angleThreshold,
                min: 40,
                max: 80,
                divisions: 40,
                label: _angleThreshold.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() => _angleThreshold = value);
                  _saveSettings();
                },
              ),
            ),
            SwitchListTile(
              title: const Text("Enable Sound Alerts"),
              value: _enableSound,
              onChanged: (value) {
                setState(() => _enableSound = value);
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: const Text("Enable Vibration Alerts"),
              value: _enableVibration,
              onChanged: (value) {
                setState(() => _enableVibration = value);
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final newSettings = AlertSettings(
      angleThreshold: _angleThreshold,
      enableSound: _enableSound,
      enableVibration: _enableVibration,
    );
    widget.onSettingsChanged(newSettings);
  }
}