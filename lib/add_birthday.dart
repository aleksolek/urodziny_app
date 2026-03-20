import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final wishesController = TextEditingController();
  final eventNameController = TextEditingController();
  final reminderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj wydarzenie')),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Data: ${widget._day.day}/${widget._day.month}/${widget._day.year}',
              ),
              TextField(
                controller: nameController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Imię",
                  hintStyle: TextStyle(color: Colors.grey),
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  labelText: "Imię",
                ),
              ),
              TextField(
                controller: phoneController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Telefon",
                  labelText: "Telefon",
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextField(
                controller: wishesController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Wpisz życzenia",
                  labelText: "Życzenia",
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextField(
                controller: eventNameController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Wpisz nazwę wydarzenia (opcjonalne)",
                  labelText: "Nazwa wydarzenia",
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextField(
                controller: reminderController,
                maxLines: null,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText:
                      "Na ile dni wcześniej wysłać przypomnienie (opcjonalne)",
                  labelText: "Przypomnienie na tyle dni wcześniej",
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
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
              ElevatedButton(
                onPressed: () => _onChoosePersonPress(context),
                child: Text('Wybierz z kontaktow'),
              ),
              ElevatedButton(
                onPressed: () => _onSavePress(
                  nameController.text,
                  phoneController.text,
                  wishesController.text,
                  eventNameController.text,
                  reminderController.text,
                ),
                child: Text('Zapisz'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showWarning(
    BuildContext context,
    String warningTitle,
    String warningText,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(warningTitle),
        content: Text(warningText),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  _onSavePress(
    String name,
    String phone,
    String wishes,
    String eventName,
    String reminder,
  ) {
    if (name == "" && eventName == "") {
      showWarning(context, "Puste pola", "Podaj imię, albo nazwę wydarzenia");
      return;
    }
    DateTime date = widget._day;
    int reminderInt = 0;
    if (reminder != "") {
      reminderInt = int.parse(reminder);
      if (reminderInt > 364) {
        showWarning(
          context,
          "Przypomnienie",
          "Przypomnienie musi być krótsze niż rok",
        );
        return;
      }
    }
    int year = 0;
    Event birthday;
    if (isOneTimeEvent) {
      year = date.year;
    }
    birthday = Event(
      name,
      phone,
      wishes,
      generateEventId(date),
      year,
      eventName,
      withoutMessage,
      reminderInt,
    );

    if (kEvents[date] == null) {
      final growableList = List<Event>.empty(growable: true);
      growableList.add(birthday);
      kEvents[date] = growableList;
    } else {
      if (kEvents[date]!.length == 99) {
        showWarning(
          context,
          'Za dużo wydarzeń',
          'Maksymalna liczba 99 wydarzeń zosatła przekroczona. Usuń jakieś wydarzenia aby móc dodawać kolejne',
        );
        return;
      }
      kEvents[date]?.add(birthday);
    }
    List<Event> tempList = kEvents[date] as List<Event>;
    _box.put(getHashCode(date), tempList);
    LocalNotifications.scheduleNotification(date.day, date.month, birthday);
    Navigator.pop(context);
  }

  _onChoosePersonPress(BuildContext context) async {
    final result = await Navigator.pushNamed(context, ChoosePersonRoute);
    if (result != null) {
      setState(() {
        receivedContact = result as Map<String, String>;
        nameController.text = receivedContact["name"]!;
        phoneController.text = receivedContact["phone"]!;
      });
    }
  }
}

int generateEventId(DateTime key) {
  if (kEvents[key] == null) {
    return 0;
  }
  int eventId = 0;
  while (true) {
    bool idUsed = false;
    for (int j = 0; j < kEvents[key]!.length; j++) {
      if (eventId == kEvents[key]![j].id) {
        idUsed = true;
        break;
      }
    }
    if (!idUsed) {
      return eventId;
    }
    eventId++;
  }
}
