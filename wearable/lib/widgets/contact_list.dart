import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import '../services/wear_phone_bridge.dart';
import 'contact_card.dart';
import 'wear_scroll_view.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  static const platform = MethodChannel('wear_os_controls');

  final _wearBridge = WearPhoneBridge();
  final _scrollController = WearScrollController();
  var _noContactsMessage = '';

  List<Contact> contacts = [];
  // [
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
    appState.loadContacts();
    _initializeRotaryInput();
  }

  Future<void> _initializeRotaryInput() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onRotaryScroll') {
        final double delta = call.arguments as double;
        _scrollController.handleRotaryScroll(delta);
      }
    });
  }

  Future<void> _openOnPhone() async {
    try {
      final success = await _wearBridge.openOnPhone();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to open app on phone. Is your phone connected?'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to phone: ${e.toString()}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final countryCode = locale.countryCode?.toLowerCase();

    if (countryCode == 'it') {
      _noContactsMessage =
          'Nessun contatto trovato, aggiungi prima un contatto '
          'da smartphone per visualizzare qui la lista.';
    } else {
      _noContactsMessage = 'No contacts found, you must add one first '
          'from your smartphone to see here the list.';
    }

    return contacts.isEmpty
        ? WearScrollView(
            controller: _scrollController,
            child: Column(children: [
              SizedBox(height: 40),
              Text(_noContactsMessage),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async => await _openOnPhone(),
                  icon: Icon(
                    Icons.phone_android,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    countryCode == 'it' ? 'Apri sul telefono' : 'Open on phone',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ]),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: ContactCard(contact: contact));
            },
          );
  }
}
