import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter/widgets/info_modal.dart';

import 'firebase_options.dart';
import 'models/contact.dart';
import 'providers/app_state.dart';
import 'settings.dart';

import 'widgets/contacts_list.dart';
import 'widgets/form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => AppState())],
    child: const TaxCodeApp(),
  ));
}

final class TaxCodeApp extends StatelessWidget {
  const TaxCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 38, 128, 0)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

final class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final class _HomePageState extends State<HomePage> {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  @override
  void initState() {
    super.initState();
    _setCache();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(AppLocalizations.of(context)!.appTitle),
              actions: [
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

  Future<String> _getAccessToken() async {
    if (Platform.isAndroid) {
      try {
        final remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.fetchAndActivate();
        return remoteConfig.getString(Settings.apiAccessTokenKey);
      } on Exception catch (e) {
        if (mounted) {
          context
              .read<AppState>()
              .logger
              .e('Error while retrieving access token from remote config: $e');
        }
      }
    }
    return '';
  }

  Future<void> _setCache() async {
    final accessToken = await _prefs.getString(Settings.apiAccessTokenKey);

    if (accessToken == null || accessToken.isEmpty) {
      await _prefs.setString(
          Settings.apiAccessTokenKey, await _getAccessToken());
    }
  }
}
