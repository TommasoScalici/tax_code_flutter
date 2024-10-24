import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import 'auth_gate.dart';
import '../widgets/contacts_list.dart';
import '../widgets/info_modal.dart';

import 'form_page.dart';
import 'profile_screen.dart';

final class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    final appState = context.read<AppState>();
    appState.loadContacts();
    appState.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (!snapshot.hasData) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AuthGate()),
              (route) => false);
        }

        return Consumer<AppState>(
          builder: (BuildContext context, AppState value, Widget? child) {
            final currentUser = auth.currentUser;

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
                                  builder: (context) => ProfileScreen()));
                        },
                        icon:
                            currentUser != null && currentUser.photoURL != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Image.network(currentUser.photoURL!),
                                  )
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
                            builder: (BuildContext context) =>
                                const InfoModal(),
                          ),
                        ),
                      ],
                    ),
                  ]),
              body: const ContactsListPage(),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final contact = await Navigator.push<Contact>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormPage(contact: null),
                      ));

                  var currentFocus = FocusManager.instance.primaryFocus;
                  if (currentFocus != null) currentFocus.unfocus();

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
      },
    );
  }
}
