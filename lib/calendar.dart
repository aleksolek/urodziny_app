import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urodziny_app/app.dart';
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/local_notifications.dart';
import 'package:urodziny_app/backup.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _Calendar();
}

class _Calendar extends State<Calendar> {
  final _box = Hive.box('birthdayEvents');
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _deleteEvent(int id) {
    final int index = getIndexFromId(_selectedDay, id);
    if (index == -1) return;
    print("Deleting event index: $index for day $_selectedDay");
    print("${kEvents[_selectedDay]?[index]}");
    LocalNotifications.deleteScheduledNotification(id);
    kEvents[_selectedDay]?.removeAt(index);
    _box.put(getHashCode(_selectedDay as DateTime), kEvents[_selectedDay]);
    setState(() {
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    List<Event>? tempList = kEvents[day];
    if (tempList == null) {
      return [];
    }
    List<Event> resultList = [];
    for (Event event in tempList) {
      if (event.year == 0 || event.year == day.year) {
        resultList.add(event);
      }
    }
    return resultList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kalendarz urodzin')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            eventLoader: _getEventsForDay,
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              // Use `selectedDayPredicate` to determine which day is currently selected.
              // If this returns true, then `day` will be marked as selected.

              // Using `isSameDay` is recommended to disregard
              // the time-part of compared DateTime objects.
              return isSameDay(_selectedDay, day);
            },
          ),
          ElevatedButton(
            onPressed: () => _onAddBirthdayTap(context),
            child: Text('Dodaj urodziny'),
          ),
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                height: 205.0,
                width: 333.0,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: value.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: value[index].year == 0
                          ? const Icon(Icons.wallet_giftcard)
                          : const Icon(Icons.expand_circle_down_outlined),
                      trailing: IconButton(
                        onPressed: () {
                          _deleteEvent(_selectedEvents.value[index].id);
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.blue,
                      ),
                      title: Text(
                        "${value[index].name}",
                      ), // Main title text that shows item index.
                      onTap: () => _onEditEventTap(context, index),
                    );
                  },
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Backup.createBackup(),
                child: Text('Eksportuj kalendarz'),
              ),
              ElevatedButton(
                onPressed: () => Backup.importBackup(context),
                child: Text('Importuj kalendarz'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _onAddBirthdayTap(BuildContext context) {
    Navigator.pushNamed(context, AddBirthdayRoute, arguments: _selectedDay);
  }

  _onEditEventTap(BuildContext context, int index) {
    Navigator.pushNamed(
      context,
      EditEventRoute,
      arguments: {"day": _selectedDay, "id": _selectedEvents.value[index].id},
    );
  }
}
