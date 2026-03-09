import 'dart:collection';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:hive/hive.dart';

part 'events.g.dart';

/// Example event class.
@HiveType(typeId: 0, adapterName: "BirthdayAdapter")
class Event extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  String wishes;
  @HiveField(4)
  int year;
  Event(
    this.name, [
    this.phone = 'No number',
    this.wishes = 'No wishes',
    this.id = 0,
    this.year = 0,
  ]);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'wishes': wishes,
    'year': year,
  };
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['name'],
      json['phone'],
      json['wishes'],
      json['id'],
      json['year'],
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
