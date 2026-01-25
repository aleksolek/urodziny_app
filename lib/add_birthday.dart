import 'package:flutter/material.dart';
import 'package:urodziny_app/events.dart';
import 'package:urodziny_app/app.dart';

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
      print('Lista na ten dzien nie istnieje jeszcze');
      final growableList = List<Event>.empty(growable: true);
      growableList.add(birthday);
      kEvents[widget._day] = growableList;
    } else {
      kEvents[widget._day]?.add(birthday);
      print(birthday);
    }
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
