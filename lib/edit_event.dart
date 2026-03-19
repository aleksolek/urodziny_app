import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:urodziny_app/local_notifications.dart';

class EditEvent extends StatefulWidget {
  final DateTime _day;
  final int _id;
  EditEvent(this._day, this._id);
  State<EditEvent> createState() => _EditEvent();
}

class _EditEvent extends State<EditEvent> {
  final _box = Hive.box('birthdayEvents');
  bool isEditActive = false;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController eventNameController;
  late TextEditingController wishesController;
  late TextEditingController reminderController;
  Event? currentEvent;
  int index = -1;
  @override
  void initState() {
    super.initState();

    index = getIndexFromId(widget._day, widget._id);
    assert(index != -1);
    currentEvent = kEvents[widget._day]?[index];
    nameController = TextEditingController(text: currentEvent?.name);
    phoneController = TextEditingController(text: currentEvent?.phone);
    eventNameController = TextEditingController(text: currentEvent?.eventName);
    wishesController = TextEditingController(text: currentEvent?.wishes);
    reminderController = TextEditingController(
      text: currentEvent?.reminder.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentEvent == null) return Text('Null event');
    return Scaffold(
      appBar: AppBar(title: Text('Edytuj wydarzenie')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isEditActive
              ? TextField(
                  controller: nameController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Imię",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                    labelText: "Imię",
                  ),
                )
              : Text('Imię: ${currentEvent?.name}'),
          isEditActive
              ? TextField(
                  controller: phoneController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Telefon",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                    labelText: "Telefon",
                  ),
                )
              : Text('Telefon: ${currentEvent?.phone}'),
          isEditActive
              ? TextField(
                  controller: eventNameController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Nazwa wydarzenia",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                    labelText: "Nazwa wydarzenia",
                  ),
                )
              : Text('Nazwa wydarzenia: ${currentEvent?.eventName}'),
          isEditActive
              ? TextField(
                  controller: wishesController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Życzenia",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                    labelText: "Życzenia",
                  ),
                )
              : Text('Życzenia: ${currentEvent?.wishes}'),
          isEditActive
              ? TextField(
                  controller: reminderController,
                  maxLines: null,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: "Przypomnienie",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                    labelText: "Przypomnienie na tyle dni wcześniej",
                  ),
                )
              : Text('Przypomnienie: ${currentEvent?.reminder} dni wcześniej'),
          ElevatedButton(
            onPressed: () => _onEditPress(),
            child: isEditActive ? Text('Zapisz') : Text('Edytuj'),
          ),
        ],
      ),
    );
  }

  _onEditPress() async {
    setState(() async {
      // When we press save:
      if (isEditActive) {
        kEvents[widget._day]?[index].name = nameController.text;
        kEvents[widget._day]?[index].phone = phoneController.text;
        kEvents[widget._day]?[index].eventName = eventNameController.text;
        kEvents[widget._day]?[index].wishes = wishesController.text;
        int reminderDays = 0;
        if (reminderController.text != "") {
          reminderDays = int.parse(reminderController.text);
        }
        kEvents[widget._day]?[index].reminder = reminderDays;
        _box.put(getHashCode(widget._day), kEvents[widget._day]);
        currentEvent = kEvents[widget._day]?[index];
        await LocalNotifications.deleteScheduledNotification(
          widget._day.day,
          widget._day.month,
          currentEvent!,
        );
        LocalNotifications.scheduleNotification(
          widget._day.day,
          widget._day.month,
          currentEvent!,
        );
      }
      isEditActive = !isEditActive;
    });
  }
}
