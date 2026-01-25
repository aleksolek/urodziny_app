import 'package:flutter/material.dart';
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/app.dart';

class EditEvent extends StatefulWidget {
  final DateTime _day;
  final int _index;
  EditEvent(this._day, this._index);
  State<EditEvent> createState() => _EditEvent();
}

class _EditEvent extends State<EditEvent> {
  bool isEditActive = false;
  late TextEditingController wishesController;
  Event? currentEvent;
  @override
  void initState() {
    super.initState();

    currentEvent = kEvents[widget._day]?[widget._index];
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
        kEvents[widget._day]?[widget._index].wishes = wishesController.text;
        currentEvent = kEvents[widget._day]?[widget._index];
      }
      isEditActive = !isEditActive;
    });
  }
}
