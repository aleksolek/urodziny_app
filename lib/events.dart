import 'dart:collection';
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
  Event(
    this.name, [
    this.phone = 'No number',
    this.wishes = 'No wishes',
    this.id = 0,
  ]);

  @override
  String toString() => name;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDayAndMonth,
  hashCode: getHashCode,
);
int getHashCode(DateTime key) {
  return key.day * 100 + key.month;
}

DateTime getDateTimeFromHashCode(int key) {
  return DateTime(2025, key % 100, (key / 100).truncate());
}

bool isSameDayAndMonth(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.month == b.month && a.day == b.day;
}
