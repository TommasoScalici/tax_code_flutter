import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';

final class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContactsListController>();
    final l10n = AppLocalizations.of(context)!;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasContacts) {
      return const SizedBox.shrink();
    }

    return _buildEmptyState(context, l10n, controller);
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ContactsListController controller,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.noContactsFoundMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),

            if (controller.isLaunchingPhoneApp)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.phone_android),
                label: Text(l10n.openOnPhone),
                onPressed: controller.launchPhoneApp,
              ),
          ],
        ),
      ),
    );
  }
}
