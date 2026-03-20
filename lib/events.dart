import 'dart:collection';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:hive/hive.dart';

part 'events.g.dart';

/// Example event class.
@HiveType(typeId: 0, adapterName: "BirthdayAdapter")
class Event extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String phone;
  @HiveField(3)
  String wishes;
  @HiveField(4)
  int year;
  @HiveField(5)
  String eventName;
  @HiveField(6)
  bool messageDisabled;
  @HiveField(7)
  int reminder;
  Event(
    this.name,
    this.phone,
    this.wishes,
    this.id,
    this.year,
    this.eventName,
    this.messageDisabled,
    this.reminder,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'wishes': wishes,
    'year': year,
    'eventName': eventName,
    'messageDisabled': messageDisabled,
    'reminder': reminder,
  };
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['name'],
      json['phone'],
      json['wishes'],
      json['id'],
      json['year'],
      json['eventName'],
      json['messageDisabled'],
      json['reminder'],
    );
  }

  @override
  String toString() => 'name: $name year: $year';
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDayAndMonth,
  hashCode: getHashCode,
);
int getHashCode(DateTime key) {
  return key.day * 100 + key.month;
}

int getIndexFromId(DateTime? day, int id) {
  if (day == null) return -1;
  if (kEvents[day] == null) return -1;
  return kEvents[day]!.indexWhere((event) => event.id == id);
}

DateTime getDateTimeFromHashCode(int key) {
  return DateTime(0, key % 100, (key / 100).truncate());
}

bool isSameDayAndMonth(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.month == b.month && a.day == b.day;
}
