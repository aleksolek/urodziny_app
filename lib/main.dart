import 'package:flutter/material.dart';
import 'package:urodziny_app/local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'package:urodziny_app/events.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BirthdayAdapter());
  await LocalNotifications.initialize();

  // open the box
  var box = await Hive.openBox('birthdayEvents');
  for (int key in box.keys) {
    DateTime keyDateTime = getDateTimeFromHashCode(key);
    final dynamicEvents = box.get(key) as List<dynamic>?;
    List<Event> convertedEvents =
        dynamicEvents?.map((event) => event as Event).toList() ?? [];
    kEvents[keyDateTime] = convertedEvents;
  }

  await initializeDateFormatting();
  runApp(const MyApp());
}
