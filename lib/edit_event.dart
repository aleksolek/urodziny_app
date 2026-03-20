import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urodziny_app/events.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:urodziny_app/local_notifications.dart';

class EditEvent extends StatefulWidget {
  final DateTime _day;
  final int _id;
  const EditEvent(this._day, this._id);
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
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Imię: ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              isEditActive
                  ? TextField(controller: nameController, maxLines: null)
                  : Text('${currentEvent?.name}'),
              SizedBox(height: 8),
              Text(
                "Telefon: ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              isEditActive
                  ? TextField(controller: phoneController, maxLines: null)
                  : Text('${currentEvent?.phone}'),
              SizedBox(height: 8),
              Text(
                "Nazwa wydarzenia: ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              isEditActive
                  ? TextField(controller: eventNameController, maxLines: null)
                  : Text('${currentEvent?.eventName}'),
              SizedBox(height: 8),
              Text(
                "Życzenia: ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              isEditActive
                  ? TextField(controller: wishesController, maxLines: null)
                  : Text('${currentEvent?.wishes}'),
              SizedBox(height: 8),
              Text(
                "Przypomnienie: ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              isEditActive
                  ? TextField(
                      controller: reminderController,
                      maxLines: null,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    )
                  : Text('${currentEvent?.reminder} dni wcześniej'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _onEditPress(),
                child: isEditActive ? Text('Zapisz') : Text('Edytuj'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onEditPress() async {
    setState(() {
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
        LocalNotifications.deleteScheduledNotification(
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
