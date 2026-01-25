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
  equals: isSameDay,
  hashCode: getHashCode,
);
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
