import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/url.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

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
      onDidReceiveNotificationResponse: onClickNotification,
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
    String fixedPhone = event.phone.replaceAll(RegExp(r'\D'), '');
    print("To nasz nowy phone: $fixedPhone");
    print("I zyczenia: ${event.wishes}");
    String fullPayload = jsonEncode({
      'phone': fixedPhone,
      'wishes': event.wishes,
    });
    for (var i = 0; i < NUMBER_OF_YEARS; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: event.id + i,
        // id: event.id,
        scheduledDate: tz.TZDateTime.local(year + i, month, day, 10),
        // scheduledDate: tz.TZDateTime.now(
        //   tz.local,
        // ).add(const Duration(seconds: 3)),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: 'Urodziny ${event.name}!',
        body: 'Nie zapomnij zlozyc zyczen',
        payload: fullPayload,
      );
    }
  }

  static Future deleteScheduledNotification(int eventId) async {
    for (var i = 0; i < NUMBER_OF_YEARS; i++) {
      await flutterLocalNotificationsPlugin.cancel(id: eventId + i);
    }
  }

  static void onClickNotification(
    NotificationResponse notificationResponse,
  ) async {
    print("Notyfikacja kliknieta");
    var payloadData = jsonDecode(notificationResponse.payload as String);
    print("Po zdekodowaniu: ${payloadData["wishes"]}");
    final Uri toLaunch = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: payloadData["phone"],
      queryParameters: {"text": payloadData["wishes"]},
    );
    // Url.LaunchInBrowser(toLaunch);
    print("Launching");
    if (!await launchUrl(toLaunch, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $toLaunch');
    }
    print("Launched");
  }

  static String strip(String str, String charactersToRemove) {
    String escapedChars = RegExp.escape(charactersToRemove);
    RegExp regex = new RegExp(
      r"^[" + escapedChars + r"]+|[" + escapedChars + r']+$',
    );
    String newStr = str.replaceAll(regex, '').trim();
    return newStr;
  }
}
