import 'package:flutter/material.dart';
import 'package:urodziny_app/local_notifications.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.initialize();
  runApp(const MyApp());
}
