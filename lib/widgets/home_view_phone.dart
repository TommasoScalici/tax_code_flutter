import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/screens/form_page.dart';

import '../models/contact.dart';
import '../providers/app_state.dart';

import 'contacts_list.dart';
import 'info_modal.dart';

class HomeViewPhone extends StatelessWidget {
  const HomeViewPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        final currentUser = FirebaseAuth.instance.currentUser;

        return Scaffold(
          appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(AppLocalizations.of(context)!.appTitle),
              actions: [
                IconButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    actions: [
                                      AccountDeletedAction(
                                          (context, user) async {
                                        final instance =
                                            FirebaseFirestore.instance;
                                        await instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .delete();
                                      }),
                                      SignedOutAction(
                                        (context) => Navigator.pop(context),
                                      )
                                    ],
                                    showDeleteConfirmationDialog: true,
                                  )));
                    },
                    icon: currentUser != null && currentUser.photoURL != null
                        ? Image.network(currentUser.photoURL!)
                        : Icon(Symbols.account_circle_filled)),
                IconButton(
                  icon: Icon(value.theme == 'dark'
                      ? Icons.light_mode_sharp
                      : Icons.mode_night_sharp),
                  onPressed: () {
                    value.toggleTheme();
                  },
                ),
                PopupMenuButton(
                  child: const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.more_vert)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.info),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(AppLocalizations.of(context)!.info),
                          )
                        ],
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => const InfoModal(),
                      ),
                    ),
                  ],
                ),
              ]),
          body: const ContactsListPage(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              var currentFocus = FocusManager.instance.primaryFocus;
              if (currentFocus != null) currentFocus.unfocus();

              final contact = await Navigator.push<Contact>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormPage(contact: null),
                  ));

              await Future.delayed(const Duration(milliseconds: 500));

              if (contact != null) {
                value.addContact(contact);
                value.saveContacts();
              }
            },
            tooltip: AppLocalizations.of(context)!.newItem,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
