import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import '../screens/barcode_page.dart';

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
    _setupMethodCallHandler();
  }

  Future<void> _loadAndShowContacts(AppState appState) async {
    setState(() => _isLoading = true);

    try {
      await appState.loadContacts();

      if (mounted) {
        print('Contacts to send: ${contacts.length}');
        final contactsData = contacts.map((c) => c.toNativeMap()).toList();
        print('Contacts mapped: $contactsData');

        await _platform.invokeMethod('openNativeContactList', {
          'contacts': contactsData,
        });
      }
    } catch (e) {
      if (mounted) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening contacts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupMethodCallHandler() {
    _platform.setMethodCallHandler((call) async {
      if (call.method == 'openBarcodePage') {
        final taxCode = call.arguments as String;
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodePage(taxCode: taxCode),
            ),
          );
          return true;
        }
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : const SizedBox(); // Questo widget sarà vuoto perché la lista è mostrata nativamente
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppState>(builder: (context, value, child) {
//       return _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : contacts.isEmpty
//               ? SingleChildScrollView(
//                   child: Column(children: [
//                     SizedBox(height: 40),
//                     Text(AppLocalizations.of(context)!.noContactsFoundMessage),
//                     SizedBox(height: 20),
//                     SizedBox(
//                       height: 50,
//                       child: ElevatedButton.icon(
//                         onPressed: () async => await _openOnPhone(),
//                         icon: Icon(
//                           Icons.phone_android,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                         label: Text(
//                           countryCode == 'it' ? 'Apri sul telefono' : 'Open on phone',
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 40),
//                   ]),
//                 )
//               : ListView.builder(
//                   controller: _scrollController,
//                   shrinkWrap: true,
//                   physics: ClampingScrollPhysics(),
//                   itemCount: contacts.length,
//                   itemBuilder: (context, index) {
//                     final contact = contacts[index];
//                     return Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10.0),
//                         child: ContactCard(contact: contact));
//                   },
//                 );
//     });
//   }
