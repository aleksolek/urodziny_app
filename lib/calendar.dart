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

  bool isDayAHoliday(DateTime day) {
    if (isSameDayAndMonth(day, DateTime(0, 1, 1)) ||
        isSameDayAndMonth(day, DateTime(0, 1, 6)) ||
        isSameDayAndMonth(day, DateTime(0, 5, 1)) ||
        isSameDayAndMonth(day, DateTime(0, 5, 3)) ||
        isSameDayAndMonth(day, DateTime(0, 8, 15)) ||
        isSameDayAndMonth(day, DateTime(0, 11, 1)) ||
        isSameDayAndMonth(day, DateTime(0, 11, 11)) ||
        isSameDayAndMonth(day, DateTime(0, 12, 24)) ||
        isSameDayAndMonth(day, DateTime(0, 12, 25)) ||
        isSameDayAndMonth(day, DateTime(0, 12, 26))) {
      return true;
    }
    return false;
  }

  void _deleteEvent(int id) async {
    bool delete = true;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Na pewno?"),
        content: Text("Czy na pewno chcesz usunąć to wydarzenie?"),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('JEDNAK NIE'),
            onPressed: () {
              delete = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('TAK USUŃ'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    if (delete == false) {
      return;
    }
    final int index = getIndexFromId(_selectedDay, id);
    if (index == -1) return;
    await LocalNotifications.deleteScheduledNotification(
      _selectedDay!.day,
      _selectedDay!.month,
      kEvents[_selectedDay]![index],
    );
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
      appBar: AppBar(title: Text('Kalendarz wydarzeń')),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          TableCalendar(
            availableGestures: AvailableGestures.none,
            daysOfWeekHeight: 20,
            holidayPredicate: isDayAHoliday,
            startingDayOfWeek: StartingDayOfWeek.monday,

            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.w400),
            ),
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                if (day.weekday == DateTime.saturday) {
                  return Center(
                    child: Text(
                      'sob',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                } else if (day.weekday == DateTime.sunday) {
                  return Center(
                    child: Text(
                      'ndz',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                } else {
                  return null;
                }
              },
              holidayBuilder: (context, date, _) {
                TextStyle style;
                style = TextStyle().copyWith(color: Colors.red);
                return Center(child: Text('${date.day}', style: style));
              },
              defaultBuilder: (context, date, _) {
                TextStyle style;
                if (date.weekday == 6) {
                  // Saturday
                  style = TextStyle().copyWith(color: Colors.blue);
                  return Center(child: Text('${date.day}', style: style));
                } else if (date.weekday == 7) {
                  // Sunday
                  style = TextStyle().copyWith(color: Colors.red);
                  return Center(child: Text('${date.day}', style: style));
                }
                return null;
              },
            ),
            locale: 'pl_PL',
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.w400),
            ),
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
            child: Text('Dodaj wydarzenie'),
          ),
          ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: value.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: value[index].eventName == ''
                          ? const Icon(Icons.wallet_giftcard)
                          : value[index].year == 0
                          ? const Icon(Icons.event_repeat)
                          : const Icon(Icons.expand_circle_down_outlined),
                      trailing: IconButton(
                        onPressed: () {
                          _deleteEvent(_selectedEvents.value[index].id);
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.deepPurple,
                      ),
                      title: Text(
                        value[index].eventName == ''
                            ? "${value[index].name}"
                            : "${value[index].eventName}",
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
                onPressed: () => Backup.createBackup(context),
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
    Navigator.pushNamed(
      context,
      AddBirthdayRoute,
      arguments: _selectedDay,
    ).then(
      (_) => setState(() {
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      }),
    );
  }

  _onEditEventTap(BuildContext context, int index) {
    Navigator.pushNamed(
      context,
      EditEventRoute,
      arguments: {"day": _selectedDay, "id": _selectedEvents.value[index].id},
    );
  }
}
