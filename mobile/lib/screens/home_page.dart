import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/widgets/contacts_list.dart';
import 'package:tax_code_flutter/widgets/info_modal.dart';

import 'form_page.dart';
import 'profile_screen.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = context.watch<AuthService>();
    final themeService = context.watch<ThemeService>();
    final homeController = context.read<HomePageController>();
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.homePageTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: currentUser != null && currentUser.photoURL != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(currentUser.photoURL!),
                  )
                : const Icon(Symbols.account_circle_filled),
          ),
          IconButton(
            icon: Icon(themeService.theme == 'dark'
                ? Icons.light_mode_sharp
                : Icons.mode_night_sharp
              ),
            onPressed: themeService.toggleTheme,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.info),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(l10n.info),
                    ),
                  ],
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => const InfoModal(),
                ),
              ),
            ],
          ),
        ],
      ),
      body: const ContactsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newContact = await Navigator.push<Contact>(
            context,
            MaterialPageRoute(builder: (context) => const FormPage()),
          );
        
          if (newContact != null) {
            homeController.saveContact(newContact);
          }
        },
        tooltip: l10n.newItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}