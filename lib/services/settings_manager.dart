import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_settings.dart';

class SettingsManager {
  static const String _angleKey = "angleThreshold";
  static const String _soundKey = "enableSound";
  static const String _vibrationKey = "enableVibration";

  static Future<AlertSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AlertSettings(
      angleThreshold: prefs.getDouble(_angleKey) ?? 70.0,
      enableSound: prefs.getBool(_soundKey) ?? true,
      enableVibration: prefs.getBool(_vibrationKey) ?? true,
    );
  }

  static Future<void> saveSettings(AlertSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_angleKey, settings.angleThreshold);
    await prefs.setBool(_soundKey, settings.enableSound);
    await prefs.setBool(_vibrationKey, settings.enableVibration);
  }
}