import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:urodziny_app/events.dart';

const int NUMBER_OF_YEARS = 30;

class LocalNotifications {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidInitializationSettings,
          iOS: iosInitializationSettings,
        );
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
  }

  static Future sendSimpleNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'plain title',
      body: 'plain body',
      notificationDetails: notificationDetails,
      payload: 'item x',
    );
  }

  static Future scheduleNotification(int day, int month, Event event) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          "scheduled",
          "scheduled notification",
          channelDescription: "this is a scheduled notification",
          importance: Importance.max,
          priority: Priority.max,
        );
    const DarwinNotificationDetails darwinNorificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      iOS: darwinNorificationDetails,
      android: androidNotificationDetails,
    );
    print(
      "Scheduling notification for the day: $day month: $month id: ${event.id}",
    );
    int year = DateTime.now().year;
    // Prevent scheduling in the past
    if (month <= DateTime.now().month) {
      if (day <= DateTime.now().day) {
        year++;
      }
    }
    for (var i = 0; i < NUMBER_OF_YEARS; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: event.id + i,
        scheduledDate: tz.TZDateTime.local(year, month, day, 10),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: 'Urodziny ${event.name}!',
        body: 'Nie zapomnij zlozyc zyczen',
      );
    }
  }

  static Future deleteScheduledNotification(int eventId) async {
    for (var i = 0; i < NUMBER_OF_YEARS; i++) {
      await flutterLocalNotificationsPlugin.cancel(id: eventId + i);
    }
  }
}
