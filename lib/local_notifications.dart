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

  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        "scheduled",
        "scheduled notification",
        channelDescription: "this is a scheduled notification",
        importance: Importance.max,
        priority: Priority.max,
      );
  static const DarwinNotificationDetails darwinNorificationDetails =
      DarwinNotificationDetails();

  static const NotificationDetails notificationDetails = NotificationDetails(
    iOS: darwinNorificationDetails,
    android: androidNotificationDetails,
  );

  // static Future sendSimpleNotification() async {
  //   const AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //         'your channel id',
  //         'your channel name',
  //         channelDescription: 'your channel description',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         ticker: 'ticker',
  //       );
  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidNotificationDetails,
  //   );
  //   await flutterLocalNotificationsPlugin.show(
  //     id: 0,
  //     title: 'plain title',
  //     body: 'plain body',
  //     notificationDetails: notificationDetails,
  //     payload: 'item x',
  //   );
  // }

  static Future scheduleZonedNotification(
    int day,
    int month,
    int year,
    int notificationId,
    String? notificationTitle,
    String? notificationBody,
    String? notificationPayload,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      scheduledDate: tz.TZDateTime.local(year, month, day, 10),
      // scheduledDate: tz.TZDateTime.now(
      //   tz.local,
      // ).add(const Duration(seconds: 3)),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: notificationTitle,
      body: notificationBody,
      payload: notificationPayload,
    );
  }

  static Future scheduleNotification(int day, int month, Event event) async {
    print(
      "Scheduling notification for the day: $day month: $month id: ${event.id}",
    );
    int yearsNumber = 1;
    int year = event.year;
    if (year == 0) {
      // It is a yearly recurring event
      yearsNumber = NUMBER_OF_YEARS;
      year = DateTime.now().year;
      // Prevent scheduling in the past
      if (DateTime.now().isAfter(DateTime(year, month, day))) {
        year++;
      }
    } else {
      // If it was just one time event scheduled in the past than return
      if (DateTime.now().isBefore(DateTime(year, month, day))) {
        return;
      }
    }
    DateTime reminderDate = DateTime(
      year,
      month,
      day,
    ).subtract(Duration(days: event.reminder));
    String fixedPhone = event.phone.replaceAll(RegExp(r'\D'), '');
    String fullPayload = jsonEncode({
      'phone': fixedPhone,
      'wishes': event.wishes,
      'messageDisabled': event.messageDisabled,
    });
    String notificationTitle = event.eventName == ''
        ? 'Urodziny ${event.name}!'
        : event.eventName;
    for (var i = 0; i < yearsNumber; i++) {
      // Main notification
      scheduleZonedNotification(
        day,
        month,
        year + i,
        event.id + i,
        notificationTitle,
        'Nie zapomnij czegoś napisać!',
        fullPayload,
      );
      // Reminder
      if (DateTime.now().isAfter(reminderDate)) {
        scheduleZonedNotification(
          reminderDate.day,
          reminderDate.month,
          reminderDate.year + i,
          event.id + i,
          notificationTitle,
          'Przygotuj się! To już niedługo: $day/$month',
          '',
        );
      }
    }
  }

  static Future deleteScheduledNotification(
    int day,
    int month,
    Event event,
  ) async {
    int baseId = getNotificationId(day, month, event.id);
    int reminderId = baseId + 100;
    int yearsNumber = 1;
    if (event.year == 0) {
      yearsNumber = NUMBER_OF_YEARS;
    }
    for (var i = 0; i < yearsNumber; i++) {
      await flutterLocalNotificationsPlugin.cancel(id: baseId + i);
      await flutterLocalNotificationsPlugin.cancel(id: reminderId + i);
    }
  }

  static Future deleteAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future scheduleAllNotifications() async {
    for (DateTime key in kEvents.keys) {
      for (Event event in kEvents[key]!) {
        scheduleNotification(key.day, key.month, event);
      }
    }
  }

  static void onClickNotification(
    NotificationResponse notificationResponse,
  ) async {
    print("Notyfikacja kliknieta");
    if (notificationResponse.payload == null ||
        notificationResponse.payload == "") {
      return;
    }
    var payloadData = jsonDecode(notificationResponse.payload as String);
    if (payloadData["messageDisabled"] == false) {
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
  }

  static String strip(String str, String charactersToRemove) {
    String escapedChars = RegExp.escape(charactersToRemove);
    RegExp regex = new RegExp(
      r"^[" + escapedChars + r"]+|[" + escapedChars + r']+$',
    );
    String newStr = str.replaceAll(regex, '').trim();
    return newStr;
  }

  static int getNotificationId(int day, int month, int eventId) {
    return day * 10000000 + month * 100000 + eventId * 1000;
  }
}
