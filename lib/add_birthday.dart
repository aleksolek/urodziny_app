import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/app.dart';
import 'package:urodziny_app/local_notifications.dart';

class AddBirthday extends StatefulWidget {
  final DateTime _day;
  AddBirthday(this._day);
  @override
  _AddBirthdayState createState() => _AddBirthdayState();
}

class _AddBirthdayState extends State<AddBirthday> {
  final _box = Hive.box('birthdayEvents');
  Map<String, String> receivedContact = {"name": '', "phone": ''};
  bool isOneTimeEvent = false;
  bool withoutMessage = false;

  @override
  Widget build(BuildContext context) {
    final wishesController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj urodziny')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Data urodzin: ${widget._day.day}/${widget._day.month}/${widget._day.year}',
          ),
          Text('Imie: ${receivedContact["name"]}'),
          Text('Telefon: ${receivedContact["phone"]}'),
          Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isOneTimeEvent,
                    onChanged: (bool? value) {
                      setState(() {
                        isOneTimeEvent = value!;
                      });
                    },
                  ),
                  Text('Jednorazowe wydarzenie'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: withoutMessage,
                    onChanged: (bool? value) {
                      setState(() {
                        withoutMessage = value!;
                      });
                    },
                  ),
                  Text('Nie wysyłaj wiadomości'),
                ],
              ),
              TextField(
                controller: wishesController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Wpisz zyczenia",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => _onChoosePersonPress(context),
                child: Text('Wybierz z kontaktow'),
              ),
              ElevatedButton(
                onPressed: () => _onSavePress(
                  receivedContact["name"] as String,
                  receivedContact["phone"] as String,
                  wishesController.text,
                ),
                child: Text('Zapisz'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget okButton = TextButton(child: Text("OK"), onPressed: () {});

  _onSavePress(String name, String phone, String wishes) {
    DateTime date = widget._day;
    Event birthday;
    if (isOneTimeEvent) {
      birthday = Event(name, phone, wishes, 0, date.year);
    } else {
      birthday = Event(name, phone, wishes);
    }
    if (kEvents[date] == null) {
      birthday.id = 1;
      print('Lista na ten dzien nie istnieje jeszcze');
      final growableList = List<Event>.empty(growable: true);
      growableList.add(birthday);
      kEvents[date] = growableList;
    } else {
      birthday.id = generateEventId(date);
      kEvents[date]?.add(birthday);
      print(birthday);
    }
    List<Event> tempList = kEvents[date] as List<Event>;
    print(tempList);
    _box.put(getHashCode(date), tempList);
    LocalNotifications.scheduleNotification(
      date.day,
      date.month,
      birthday,
      withoutMessage,
    );
    Navigator.pop(context);
  }

  _onChoosePersonPress(BuildContext context) async {
    final result = await Navigator.pushNamed(context, ChoosePersonRoute);
    if (result != null) {
      setState(() {
        receivedContact = result as Map<String, String>;
      });
    }
  }
}

int generateEventId(DateTime key) {
  int eventId = 0;
  if (kEvents[key] == null) {
    eventId = key.day * 1000000 + key.month * 10000 + 1 * 100;
    return eventId;
  }
  int id = 1;
  while (true) {
    bool idUsed = false;
    for (int j = 0; j < kEvents[key]!.length; j++) {
      if (id == kEvents[key]![j].id) {
        idUsed = true;
        break;
      }
    }
    if (!idUsed) {
      eventId = key.day * 1000000 + key.month * 10000 + id * 100;
      return eventId;
    }
    id++;
  }
}
