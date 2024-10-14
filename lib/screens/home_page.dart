import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/contact.dart';
import '../providers/app_state.dart';

import '../screens/form_page.dart';
import '../widgets/contacts_list.dart';
import '../widgets/info_modal.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(AppLocalizations.of(context)!.appTitle),
              actions: [
                IconButton(
                  icon: Icon(value.theme.brightness == Brightness.dark
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
              final contact = await Navigator.push<Contact>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormPage(contact: null),
                  ));

              var currentFocus = FocusManager.instance.primaryFocus;

              if (currentFocus != null) currentFocus.unfocus();

              await Future.delayed(const Duration(milliseconds: 500));
              if (contact != null) value.addContact(contact);
            },
            tooltip: AppLocalizations.of(context)!.newItem,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
