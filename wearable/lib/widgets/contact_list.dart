import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  static const _platform =
      MethodChannel('tommasoscalici.tax_code_flutter_wear_os/channel');

  bool _isLoading = false;

  List<Contact> contacts = [
    Contact(
      id: '1',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA85L14H501Z',
      birthPlace: Birthplace(name: 'Roma', state: 'RM'),
      birthDate: DateTime(1985, 7, 14),
      listIndex: 1,
    ),
    Contact(
      id: '2',
      firstName: 'Luigi',
      lastName: 'Verdi',
      gender: 'M',
      taxCode: 'VRDLGU90E21F205Z',
      birthPlace: Birthplace(name: 'Milano', state: 'MI'),
      birthDate: DateTime(1990, 5, 21),
      listIndex: 2,
    ),
    Contact(
      id: '3',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA85L14H501Z',
      birthPlace: Birthplace(name: 'Roma', state: 'RM'),
      birthDate: DateTime(1985, 7, 14),
      listIndex: 3,
    ),
    Contact(
      id: '4s',
      firstName: 'Luigi',
      lastName: 'Verdi',
      gender: 'M',
      taxCode: 'VRDLGU90E21F205Z',
      birthPlace: Birthplace(name: 'Milano', state: 'MI'),
      birthDate: DateTime(1990, 5, 21),
      listIndex: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();

    final appState = context.read<AppState>();
    _loadAndShowContacts(appState);
  }

  Future<void> _loadAndShowContacts(AppState appState) async {
    setState(() => _isLoading = true);

    try {
      await appState.loadContacts();

      if (mounted) {
        final contactsData = contacts.map((c) => c.toNativeMap()).toList();
        print(
            "Flutter: Calling openNativeContactList with ${contactsData.length} contacts"); // Log

        await _platform.invokeMethod('openNativeContactList', {
          'contacts': contactsData,
        });
        print("Flutter: Called openNativeContactList successfully"); // Log
      }
    } catch (e) {
      print("Flutter: Error in _loadAndShowContacts: $e"); // Log
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : const SizedBox();
  }
}
