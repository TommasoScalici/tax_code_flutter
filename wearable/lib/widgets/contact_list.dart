import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import 'contact_card.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  bool _isLoading = false;

  // List<Contact> contacts = [
  //   Contact(
  //     id: '1',
  //     firstName: 'Mario',
  //     lastName: 'Rossi',
  //     gender: 'M',
  //     taxCode: 'RSSMRA85L14H501Z',
  //     birthPlace: Birthplace(name: 'Roma', state: 'RM'),
  //     birthDate: DateTime(1985, 7, 14),
  //     listIndex: 1,
  //   ),
  //   Contact(
  //     id: '2',
  //     firstName: 'Luigi',
  //     lastName: 'Verdi',
  //     gender: 'M',
  //     taxCode: 'VRDLGU90E21F205Z',
  //     birthPlace: Birthplace(name: 'Milano', state: 'MI'),
  //     birthDate: DateTime(1990, 5, 21),
  //     listIndex: 2,
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();

    Future.microtask(() async {
      setState(() => _isLoading = true);
      await appState.loadContacts();
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, value, child) {
      return _isLoading
          ? Center(child: CircularProgressIndicator())
          : value.contacts.isEmpty
              ? SingleChildScrollView(
                  child: Column(children: [
                    SizedBox(height: 40),
                    Text(AppLocalizations.of(context)!.noContactsFoundMessage),
                    SizedBox(height: 20),
                    // SizedBox(
                    //   height: 50,
                    //   child: ElevatedButton.icon(
                    //     onPressed: () async => await _openOnPhone(),
                    //     icon: Icon(
                    //       Icons.phone_android,
                    //       color: Theme.of(context).colorScheme.primary,
                    //     ),
                    //     label: Text(
                    //       countryCode == 'it' ? 'Apri sul telefono' : 'Open on phone',
                    //       style: TextStyle(
                    //         color: Theme.of(context).colorScheme.primary,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 40),
                  ]),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: value.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = value.contacts[index];
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: ContactCard(contact: contact));
                  },
                );
    });
  }
}
