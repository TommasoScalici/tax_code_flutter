import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
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

  final Logger _logger = Logger();
  bool _isLoading = false;

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
        final contactsData =
            appState.contacts.map((c) => c.toNativeMap()).toList();

        await _platform.invokeMethod('openNativeContactList', {
          'contacts': contactsData,
        });
      }
    } catch (e) {
      _logger.e('Error while loading contact list: $e');
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
