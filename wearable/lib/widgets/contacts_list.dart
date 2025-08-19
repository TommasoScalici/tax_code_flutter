import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';

final class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  bool _isLaunchingPhoneApp = false;
  bool _isNativeViewActive = false;

  @override
  Widget build(BuildContext context) {
    final contactRepo = context.watch<ContactRepository>();
    final nativeViewService = context.read<NativeViewServiceAbstract>();
    final currentContacts = contactRepo.contacts;
    final l10n = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (currentContacts.isNotEmpty && !_isNativeViewActive) {
        nativeViewService.showContactList(currentContacts);
        setState(() {
          _isNativeViewActive = true;
        });
      } else if (_isNativeViewActive) {
        nativeViewService.updateContactList(currentContacts);
        if (currentContacts.isEmpty) {
          setState(() {
            _isNativeViewActive = false;
          });
        }
      }
    });

    if (contactRepo.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isNativeViewActive) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.noContactsFoundMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (_isLaunchingPhoneApp)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.phone_android),
                label: Text(l10n.openOnPhone),
                onPressed: _handleLaunchPhoneApp,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLaunchPhoneApp() async {
    final logger = context.read<Logger>();

    setState(() {
      _isLaunchingPhoneApp = true;
    });

    final nativeViewService = context.read<NativeViewServiceAbstract>();

    try {
      await nativeViewService.launchPhoneApp();
    } catch (e, s) {
      logger.e('Error launching phone app', error: e, stackTrace: s);
    } finally {
      if (mounted) {
        setState(() {
          _isLaunchingPhoneApp = false;
        });
      }
    }
  }
}
