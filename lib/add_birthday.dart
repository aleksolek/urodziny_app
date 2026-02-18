import 'package:flutter/material.dart';
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
  Map<String, String> receivedContact = {"name": '', "phone": ''};
  @override
  Widget build(BuildContext context) {
    final wishesController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj urodziny')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Data urodzin: ${widget._day.day}/${widget._day.month}'),
          Text('Imie: ${receivedContact["name"]}'),
          Text('Telefon: ${receivedContact["phone"]}'),
          Column(
            children: [
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
    if (name == "" || phone == "" || wishes == "") {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Puste pola"),
          content: Text("Niektore pola sa puste"),
          actions: [okButton],
        ),
      );
      return;
    }
    Event birthday = Event(name, phone, wishes);
    if (kEvents[widget._day] == null) {
      birthday.id = 1;
      print('Lista na ten dzien nie istnieje jeszcze');
      final growableList = List<Event>.empty(growable: true);
      growableList.add(birthday);
      kEvents[widget._day] = growableList;
    } else {
      birthday.id = generateEventId(widget._day);
      kEvents[widget._day]?.add(birthday);
      print(birthday);
    }
    LocalNotifications.scheduleNotification(
      widget._day.day,
      widget._day.month,
      birthday,
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
