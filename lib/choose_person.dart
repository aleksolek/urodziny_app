import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ChoosePerson extends StatefulWidget {
  const ChoosePerson();
  State<ChoosePerson> createState() => _ChoosePersonState();
}

class _ChoosePersonState extends State<ChoosePerson> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;
  Map<String, String> chosenContact = {"name": 'NoName', "phone": 'NoPhone'};
  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kontakty')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_permissionDenied) return Center(child: Text('Permission denied'));
    if (_contacts == null) return Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(_contacts![i].displayName),
        onTap: () async {
          final fullContact = await FlutterContacts.getContact(
            _contacts![i].id,
          );
          chosenContact = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactPage(fullContact!)),
          );
          Navigator.pop(context, chosenContact);
        },
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  ContactPage(this.contact);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(contact.displayName)),
    body: Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          height: 205.0,
          width: 333.0,
          child: ListView.builder(
            itemCount: contact.phones.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(contact.phones[i].number),
              onTap: () async {
                Navigator.pop(context, {
                  "name": contact.displayName,
                  "phone": contact.phones[i].number,
                });
              },
            ),
          ),
        ),
      ],
    ),
  );
}
