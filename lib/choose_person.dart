import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ChoosePerson extends StatefulWidget {
  const ChoosePerson();
  State<ChoosePerson> createState() => _ChoosePersonState();
}

class _ChoosePersonState extends State<ChoosePerson> {
  List<Contact>? _contacts;
  List<Contact>? _filteredContacts;
  bool _permissionDenied = false;
  Map<String, String> chosenContact = {"name": 'NoName', "phone": 'NoPhone'};
  @override
  void initState() {
    super.initState();
    _fetchContacts();
    _filteredContacts = _contacts;
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Contact>? results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _contacts;
    } else {
      results = _contacts!
          .where(
            (contact) => contact.displayName.toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _filteredContacts = results;
    });
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
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
    if (_filteredContacts == null)
      return Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => _runFilter(value),
            decoration: const InputDecoration(
              labelText: 'Wyszukaj',
              labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
              suffixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts!.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_filteredContacts![i].displayName),
                onTap: () async {
                  final fullContact = await FlutterContacts.getContact(
                    _filteredContacts![i].id,
                  );
                  chosenContact = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactPage(fullContact!),
                    ),
                  );
                  Navigator.pop(context, chosenContact);
                },
              ),
            ),
          ),
        ],
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
