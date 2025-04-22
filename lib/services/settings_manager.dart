import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_settings.dart';
import 'package:logging/logging.dart' as logging;

class SettingsManager {
  static const String _angleKey = "angleThreshold";
  static const String _soundKey = "enableSound";
  static const String _vibrationKey = "enableVibration";

  static final logging.Logger _logger = logging.Logger("SettingsManager");

  static Future<AlertSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AlertSettings(
        angleThreshold: prefs.getDouble(_angleKey) ?? 70.0,
        enableSound: prefs.getBool(_soundKey) ?? true,
        enableVibration: prefs.getBool(_vibrationKey) ?? true,
    );
    } catch (e) {
      _logger.severe("Failed to load settings: $e");
      return AlertSettings(
        angleThreshold: 70.0, 
        enableSound: true, 
        enableVibration: true,
      ); // Fallback to default
    }
    
  }

  static Future<void> saveSettings(AlertSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_angleKey, settings.angleThreshold);
    await prefs.setBool(_soundKey, settings.enableSound);
    await prefs.setBool(_vibrationKey, settings.enableVibration);
  }
}