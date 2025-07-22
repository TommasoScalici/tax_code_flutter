import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

final class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  static const _platform =
      MethodChannel('tommasoscalici.tax_code_flutter_wear_os/channel');

  final Logger _logger = Logger();
  bool _nativeViewShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.contacts.isEmpty) {
      _nativeViewShown = false;
    }
  }

  Future<void> _showNativeContacts(List<Contact> contacts) async {
    if (!mounted || _nativeViewShown) return;

    _nativeViewShown = true;
    _logger.i('Invoking native contact list view.');

    try {
      final contactsData = contacts.map((c) => c.toNativeMap()).toList();
      await _platform.invokeMethod('openNativeContactList', {
        'contacts': contactsData,
      });
    } on PlatformException catch (e) {
      _logger.e("Failed to invoke native method: '${e.message}'.");
      _nativeViewShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appState.contacts.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNativeContacts(appState.contacts);
          });
        }

        // Return an empty widget, as the UI is fully handled by the native side.
        return const SizedBox.shrink();
      },
    );
  }
}
