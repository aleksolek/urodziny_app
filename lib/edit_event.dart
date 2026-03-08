import 'package:flutter/material.dart';
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EditEvent extends StatefulWidget {
  final DateTime _day;
  final int _id;
  EditEvent(this._day, this._id);
  State<EditEvent> createState() => _EditEvent();
}

class _EditEvent extends State<EditEvent> {
  final _box = Hive.box('birthdayEvents');
  bool isEditActive = false;
  late TextEditingController wishesController;
  Event? currentEvent;
  int index = -1;
  @override
  void initState() {
    super.initState();

    index = getIndexFromId(widget._day, widget._id);
    assert(index != -1);
    currentEvent = kEvents[widget._day]?[index];
    wishesController = TextEditingController(text: currentEvent?.wishes);
  }

  @override
  Widget build(BuildContext context) {
    if (currentEvent == null) return Text('Null event');
    return Scaffold(
      appBar: AppBar(title: Text('Edytuj urodziny')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Imie: ${currentEvent?.name}'),
          Text('Numer: ${currentEvent?.phone}'),
          isEditActive
              ? TextField(controller: wishesController, maxLines: null)
              : Text('Zyczenia: ${currentEvent?.wishes}'),
          ElevatedButton(
            onPressed: () => _onEditPress(),
            child: isEditActive ? Text('Zapisz') : Text('Edytuj zyczenia'),
          ),
        ],
      ),
    );
  }

  _onEditPress() {
    setState(() {
      // When we press save:
      if (isEditActive) {
        kEvents[widget._day]?[index].wishes = wishesController.text;
        _box.put(getHashCode(widget._day), kEvents[widget._day]);
        currentEvent = kEvents[widget._day]?[index];
      }
      isEditActive = !isEditActive;
    });
  }
}
