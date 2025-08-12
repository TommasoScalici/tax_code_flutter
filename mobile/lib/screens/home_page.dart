import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

import '../widgets/contacts_list.dart';
import '../widgets/info_modal.dart';

import 'form_page.dart';
import 'profile_screen.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final themeService = context.watch<ThemeService>();
    final contactRepo = context.read<ContactRepository>();
    
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()));
                },
                icon: currentUser != null && currentUser.photoURL != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(currentUser.photoURL!),
                      )
                    : const Icon(Symbols.account_circle_filled)),
            IconButton(
              icon: Icon(themeService.theme == 'dark'
                  ? Icons.light_mode_sharp
                  : Icons.mode_night_sharp),
              onPressed: () {
                themeService.toggleTheme();
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
      body: const ContactsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final contact = await Navigator.push<Contact>(
              context,
              MaterialPageRoute(
                builder: (context) => const FormPage(contact: null),
              ));

          var currentFocus = FocusManager.instance.primaryFocus;
          if (currentFocus != null) currentFocus.unfocus();

          await Future.delayed(const Duration(milliseconds: 200));

          if (contact != null) {
            contactRepo.addOrUpdateContact(contact);
          }
        },
        tooltip: AppLocalizations.of(context)!.newItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}