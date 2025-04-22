import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logging/logging.dart' as logging;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../services/settings_manager.dart';
import '../screens/settings_screen.dart';

class PostureScreen extends StatefulWidget {
  const PostureScreen({super.key});

  @override
  PostureScreenState createState() => PostureScreenState();
}

class PostureScreenState extends State<PostureScreen> {
  String postureStatus = "Waiting for data...";
  late MqttServerClient _client;
  final logging.Logger _logger = logging.Logger('PostureScreen');
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Public method to update _postureStatus
  void updatePostureStatus(String newStatus) {
    setState(() {
      postureStatus = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(1.0);
    _audioPlayer.setSource(AssetSource('sounds/alert.mp3'));
    _connectToMqtt();
  }

  Future<void> _connectToMqtt({int retryCount=0, int maxRetries = 5}) async {
    _client = MqttServerClient('218638469dfa429db85a2e1df0b4f8c7.s1.eu.hivemq.cloud', 'flutter_client');
    _client.port = 8883;
    _client.keepAlivePeriod = 20;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;

    _client.logging(on: true);

    _client.secure = true;
    _client.onBadCertificate = (dynamic certificate) => true;
    _client.setProtocolV311();
    _client.connectionMessage = MqttConnectMessage()
      .withClientIdentifier('flutter_client')
      .startClean()
      .withWillQos(MqttQos.atMostOnce)
      .authenticateAs('hivemq.webclient.1742574310428', '61b!5CgSPQc>xqu.3@JM');
    
    if (retryCount >= maxRetries){
      updatePostureStatus("Failed to connect to MQTT broket after $maxRetries attempts.");
      return;
    }

    try {
      _logger.info('Attempting to connect to MQTT broker...');
      await _client.connect();
    } catch (e) {
      _logger.severe("Connection failed: $e");
      _client.disconnect();
      updatePostureStatus("Connection Failed. Retyring...");
      await Future.delayed(Duration(seconds: 2 * (retryCount + 1)));
      _connectToMqtt(retryCount: retryCount + 1, maxRetries: maxRetries);
    }
  }

  void _onConnected() {
    _logger.info('Connected to MQTT broker');
    _client.subscribe('alert/posture', MqttQos.atMostOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
      if (messages.isNotEmpty) {
        final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        final jsonPayload = jsonDecode(payload);
        final double angle = jsonPayload['angle'];

        final settings = await SettingsManager.loadSettings();

        if (angle > settings.angleThreshold) {
          updatePostureStatus('Incorrect Posture!\nAngle: ${angle.toStringAsFixed(1)}°');
          if (settings.enableSound) await _playAlertSound();
          if (settings.enableVibration) await _triggerVibration();
        } else {
          updatePostureStatus('Good Posture!\nAngle: ${angle.toStringAsFixed(1)}°');
        }
      }
    });
  }

  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      try{
        await Vibration.vibrate(duration: 500);
      } catch (e) {
        _logger.warning("Vibration failed: $e");
      }
    } else{
      _logger.info("Device does not support vibration");
    }
  }
  void _onDisconnected() {
    _logger.info('Disconnected from MQTT broker');
  }

  void _onSubscribed(String topic) {
    _logger.info('Subscribed to $topic');
  }

  Future<void> _playAlertSound() async{
    try{
      await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
    } catch (e) {
      _logger.severe("Failed to play alert sound: $e");
    }
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: const Text('Posture Detector', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: Center(
        child: _client.connectionStatus?.state == MqttConnectionState.connecting
        ? CircularProgressIndicator()
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Posture Status:',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              postureStatus,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: postureStatus.contains("Incorrect") ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) async {
    final settings = await SettingsManager.loadSettings();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          initialSettings: settings,
          onSettingsChanged: (newSettings) {
            SettingsManager.saveSettings(newSettings);
          },
        ),
      ),
    );
  }
}