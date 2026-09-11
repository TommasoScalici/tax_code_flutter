import 'dart:async';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/review_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_empty_state.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_search_bar.dart';

import 'contact_card.dart';

final class ContactsList extends StatefulWidget {
  final double? cardHeight;
  final VoidCallback? onAddContact;

  const ContactsList({
    super.key,
    this.cardHeight,
    this.onAddContact,
  });

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomePageController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text != controller.searchText) {
      _searchController.value = _searchController.value.copyWith(
        text: controller.searchText,
        selection: TextSelection.collapsed(
          offset: controller.searchText.length,
        ),
      );
    }

    return Column(
      children: [
        DashboardSearchBar(
          controller: _searchController,
          cardCount: controller.contactsToShow.length,
          onChanged: controller.filterContacts,
          onClear: () {
            FocusScope.of(context).unfocus();
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 90.0),
            child: controller.contactsToShow.isEmpty
                ? DashboardEmptyState(
                    searchQuery: controller.searchText.isNotEmpty
                        ? controller.searchText
                        : null,
                    onClearSearch: () {
                      controller.filterContacts('');
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                    onAddContact: widget.onAddContact,
                  )
                : _buildContactsGrid(context, controller),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildContactCardItem(
    BuildContext context,
    HomePageController controller,
    Contact contact,
  ) {
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

  Widget _buildContactsGrid(
    BuildContext context,
    HomePageController controller,
  ) {
    const fixedGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      mainAxisExtent: 280,
      maxCrossAxisExtent: 800,
    );

    final gridDelegate = widget.cardHeight != null
        ? SliverGridDelegateWithMaxCrossAxisExtent(
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            mainAxisExtent: widget.cardHeight,
            maxCrossAxisExtent: 800,
          )
        : fixedGridDelegate;

    if (controller.isReorderable) {
      return AnimatedReorderableGridView(
        items: controller.contactsToShow,
        sliverGridDelegate: gridDelegate,
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
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        final contact = controller.contactsToShow[index];
        return _buildContactCardItem(context, controller, contact);
      },
    );
  }

  Future<void> _onEdit(
    BuildContext context,
    HomePageController controller,
    Contact contact,
  ) async {
    final editedContact = await Navigator.pushNamed<Contact>(
      context,
      Routes.form,
      arguments: contact,
    );
    if (editedContact != null) {
      controller.saveContact(editedContact);

      if (!context.mounted) return;
      final reviewService = context.read<ReviewService>();
      await reviewService.incrementSuccessfulCalculations();

      if (!context.mounted) return;
      final inAppReviewService = context.read<InAppReviewService>();
      await inAppReviewService.maybeRequestReview();
    }
  }

  Future<void> _onDelete(
    BuildContext context,
    HomePageController controller,
    Contact contact,
  ) async {
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
    Navigator.pushNamed(context, Routes.barcode, arguments: contact.taxCode);
  }
}
