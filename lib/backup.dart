import 'package:urodziny_app/events.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:urodziny_app/local_notifications.dart';

class Backup {
  static final box = Hive.box('birthdayEvents');
  static Future createBackup(BuildContext context) async {
    if (box.isEmpty) {
      return;
    }
    String json = "{";
    for (int key in box.keys) {
      final dynamicEvents = box.get(key) as List<dynamic>?;
      List<Event> convertedEvents =
          dynamicEvents?.map((event) => event as Event).toList() ?? [];
      if (convertedEvents.isNotEmpty) {
        json += "\"";
        json += key.toString();
        json += "\":[";
        for (Event event in convertedEvents) {
          json += jsonEncode(event);
          json += ",";
        }
        json = json.substring(0, json.length - 1);
        json += '],';
      }
    }
    if (json.endsWith(',')) {
      json = json.substring(0, json.length - 1);
    }
    json += "}";
    String dir = await getFolder();
    String formattedDate = DateTime.now()
        .toString()
        .replaceAll('.', '-')
        .replaceAll(' ', '-')
        .replaceAll(':', '-');
    String path = '${dir}KalendarzUrodzinBackup$formattedDate.json';
    File backupFile = File(path);
    await backupFile.writeAsString(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eksport zakonczony sukcesem')),
    );
  }

  static Future importBackup(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      File file = File(result.files.single.path.toString());
      Map<String, dynamic> map = jsonDecode(await file.readAsString());
      map.forEach((key, value) {
        List<Event> list = List<Event>.from(
          value.map((data) => Event.fromJson(data)).toList(),
        );
        int keyInt = int.parse(key);
        box.put(keyInt, list);
        DateTime keyDateTime = getDateTimeFromHashCode(keyInt);
        kEvents[keyDateTime] = list;
      });
      await LocalNotifications.deleteAllNotifications();
      await LocalNotifications.scheduleAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import zakonczony sukcesem')),
      );
    }
  }

  static Future<String> getFolder() async {
    final dir = Directory((await getExternalStorageDirectory())!.path);
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }
}
