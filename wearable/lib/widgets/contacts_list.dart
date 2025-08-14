import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';

final class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  static const _platform =
      MethodChannel('tommasoscalici.tax_code_flutter_wear_os/channel');

  late final Logger _logger;
  bool _nativeViewShown = false;

  @override
  void initState() {
    super.initState();
    _logger = context.read<Logger>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final contactRepo = context.watch<ContactRepository>();

    if (contactRepo.contacts.isEmpty) {
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
    return Consumer<ContactRepository>(
      builder: (context, contactRepo, child) {
        if (contactRepo.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (contactRepo.contacts.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNativeContacts(contactRepo.contacts);
          });
        }

        // Return an empty widget, as the UI is fully handled by the native side.
        return const SizedBox.shrink();
      },
    );
  }
}
