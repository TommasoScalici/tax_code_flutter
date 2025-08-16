import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/screens/barcode_page.dart';
import 'package:tax_code_flutter/screens/form_page.dart';

import 'contact_card.dart';

final class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomePageController>();
    final l10n = AppLocalizations.of(context)!;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.contactsToShow.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            controller.searchText.isEmpty
                ? l10n.contactsListEmpty
                : l10n.searchNoResults(controller.searchText),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: 400,
          child: TextField(
            onChanged: controller.filterContacts,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.search,
              suffix: controller.searchText.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.filterContacts('');
                        FocusScope.of(context).unfocus(); 
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 90.0),
            child: _buildContactsGrid(context, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCardItem(BuildContext context, HomePageController controller, Contact contact) {
    return Center(
      key: ValueKey(contact.id),
      child: ContactCard(
        contact: contact,
        onShare: () => controller.shareContact(contact),
        onShowBarcode: () => _onShowBarcode(context, contact),
        onEdit: () => _onEdit(context, controller, contact),
        onDelete: () => _onDelete(context, controller, contact),
      ),
    );
  }

  Widget _buildContactsGrid(BuildContext context, HomePageController controller) {
    if (controller.isReorderable) {
      return AnimatedReorderableGridView(
        items: controller.contactsToShow,
        sliverGridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 50,
          mainAxisExtent: 280,
          maxCrossAxisExtent: 800,
        ),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final contact = controller.contactsToShow[index];
          return _buildContactCardItem(context, controller, contact);
        },
        onReorder: controller.reorderContacts,
        onReorderStart: (_) => HapticFeedback.heavyImpact(),
        isSameItem: (a, b) => a.id == b.id,
      );
    }

    return GridView.builder(
      itemCount: controller.contactsToShow.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 50,
        mainAxisExtent: 280,
        maxCrossAxisExtent: 800,
      ),
      itemBuilder: (context, index) {
        final contact = controller.contactsToShow[index];
        return _buildContactCardItem(context, controller, contact);
      },
    );
  }

  Future<void> _onEdit(BuildContext context, HomePageController controller, Contact contact) async {
    final editedContact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(builder: (context) => FormPage(contact: contact)),
    );
    if (editedContact != null) {
      controller.saveContact(editedContact);
    }
  }

  Future<void> _onDelete(BuildContext context, HomePageController controller, Contact contact) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmation),
        content: Text(l10n.deleteMessage(contact.taxCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (isConfirmed == true) {
      controller.deleteContact(contact);
    }
  }

   void _onShowBarcode(BuildContext context, Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BarcodePage(taxCode: contact.taxCode)),
    );
  }
}