import 'package:flutter/material.dart';
import 'package:logging/logging.dart' as logging;
import 'screens/posture_screen.dart';

void main() {
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen((record) {
    logging.Logger('Main').info('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const PostureApp());
}

class PostureApp extends StatelessWidget {
  const PostureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posture Detector',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PostureScreen(),
    );
  }
}