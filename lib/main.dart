import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logging/logging.dart' as logging;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() {
  // Configure logging
  logging.Logger.root.level = logging.Level.ALL; // Set the logging level
  logging.Logger.root.onRecord.listen((record) {
    logging.Logger('Main').info('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(PostureApp());
}

class PostureApp extends StatelessWidget {
  const PostureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posture Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PostureScreen(),
    );
  }
}

class PostureScreen extends StatefulWidget {
  const PostureScreen({super.key});

  @override
  PostureScreenState createState() => PostureScreenState(); // Make the state class public
}

class PostureScreenState extends State<PostureScreen> { 
  String postureStatus = "Waiting for data..."; 
  late MqttServerClient _client;
  final logging.Logger _logger = logging.Logger('PostureScreen');
  //final AudioPlayer _audioPlayer = AudioPlayer();

  // Public method to update _postureStatus
  void updatePostureStatus(String newStatus) {
    setState(() {
      postureStatus = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  Future<void> _connectToMqtt() async {
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

    try {
      _logger.info('Attempting to connect to MQTT broker...');
      await _client.connect();
    } catch (e) {
      _logger.severe("Connection failed: $e");
      _client.disconnect();
      updatePostureStatus("Connection Failed. Retyring...");
      await Future.delayed(Duration(seconds: 5));
      _connectToMqtt();
    }
  }

  void _onConnected() {
    _logger.info('Connected to MQTT broker');
    _client.subscribe('alert/posture', MqttQos.atMostOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      if (messages.isNotEmpty) {
        final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

        final jsonPayload = jsonDecode(payload);
        final String alertMessage = jsonPayload['message'];
        final double angle = jsonPayload['angle'];

        updatePostureStatus('$alertMessage\nAngle: $angle');

        if (alertMessage.toLowerCase().contains('incorrect posture')) {
          _playAlertSound();
        } 
      }
    });
  }

  void _onDisconnected() {
    _logger.info('Disconnected from MQTT broker');
  }

  void _onSubscribed(String topic) {
    _logger.info('Subscribed to $topic');
  }

  Future<void> _playAlertSound() async{
    await AudioPlayer().play(AssetSource('sounds/alert.mp3'));
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
        title: Text(
          'Posture Detector',
          style: TextStyle(color: Colors.white)),
        
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Posture Status:',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              postureStatus,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color:Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}