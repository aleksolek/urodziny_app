import 'package:flutter/material.dart';
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/app.dart';

class AddBirthday extends StatelessWidget {
  final DateTime _day;

  AddBirthday(this._day);
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey();
    final nameController = TextEditingController();
    final wishesController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj urodziny')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$_day'),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(label: Text('Imie')),
                ),
                TextFormField(
                  controller: wishesController,
                  decoration: const InputDecoration(label: Text('Zyczenia')),
                ),
                ElevatedButton(
                  onPressed: () => _onChoosePersonPress(context),
                  child: Text('Wybierz z kontaktow'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _onSavePress(nameController.text, wishesController.text),
                  child: Text('Zapisz'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _onSavePress(String name, String wishes) {
    Event birthday = Event(name, wishes);
    if (kEvents[_day] == null) {
      print('Lista na ten dzien nie istnieje jeszcze');
      final growableList = List<Event>.empty(growable: true);
      growableList.add(birthday);
      kEvents[_day] = growableList;
    } else {
      kEvents[_day]?.add(birthday);
      print(birthday);
    }
  }

  _onChoosePersonPress(BuildContext context) {
    Navigator.pushNamed(context, ChoosePersonRoute);
  }
}
