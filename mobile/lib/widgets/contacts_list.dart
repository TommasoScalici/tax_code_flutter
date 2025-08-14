import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

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
        onShowBarcode: () => controller.showBarcodeForContact(context, contact),
        onEdit: () => controller.editContact(context, contact),
        onDelete: () => controller.deleteContact(context, contact),
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
}