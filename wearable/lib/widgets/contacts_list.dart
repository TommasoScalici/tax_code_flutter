import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';

final class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final contactRepo = context.watch<ContactRepository>();
    final l10n = AppLocalizations.of(context)!;

    if (contactRepo.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (contactRepo.contacts.isEmpty) {
      return Center(
        child: Text(
          l10n.noContactsFoundMessage,
          textAlign: TextAlign.center,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}