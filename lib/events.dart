import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String name;
  final String phone;
  String wishes;
  Event(this.name, [this.phone = 'No number', this.wishes = 'No wishes']);

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

bool isSameDayAndMonth(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.month == b.month && a.day == b.day;
}
