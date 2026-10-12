import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_confirmation_dialog.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contact_card.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contacts_empty_state.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contacts_list_footer.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contacts_list_header.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_scrollbar.dart';

/// The primary contact list view for Wear OS.
///
/// Handles:
/// - Rotary crown/bezel scrolling via [PointerScrollEvent].
/// - High-contrast OLED dark cards with live tap feedback.
/// - Integrated time header and empty/loading states.
/// - Quick actions to open companion app on phone or sign out.
class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _scrollController.hasClients) {
      final target = (_scrollController.offset + event.scrollDelta.dy)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(target);
    }
  }

  void _openBarcodePage(BuildContext context, Contact contact) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BarcodePage(
          taxCode: contact.taxCode,
          contact: contact,
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showWearConfirmationDialog(
      context: context,
      title: l10n.logoutConfirmation,
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<AuthService>().signOut();
      } on Object {
        // Safe fallback if AuthService is not in the widget tree in testing
      }
    }
  }

  Future<void> _confirmExitDemo(
    BuildContext context,
    ContactsListController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showWearConfirmationDialog(
      context: context,
      title: l10n.exitDemoConfirmation,
    );

    if (confirmed == true && context.mounted) {
      controller.exitDemoMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContactsListController>();
    final l10n = AppLocalizations.of(context)!;

    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: WearDimensions.progressStrokeWidth,
          color: AppColors.emeraldPrimary,
        ),
      );
    }

    if (!controller.hasContacts) {
      return WearContactsEmptyState(
        scrollController: _scrollController,
        onPointerSignal: _onPointerSignal,
        isLaunchingPhoneApp: controller.isLaunchingPhoneApp,
        isDemoMode: controller.isDemoMode,
        onOpenOnPhone: controller.launchPhoneApp,
        onAuthAction: controller.isDemoMode
            ? () => _confirmExitDemo(context, controller)
            : () => _confirmSignOut(context),
      );
    }

    final contacts = controller.contacts;

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: WearScrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          padding: WearDimensions.listPadding,
          itemCount: contacts.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return WearContactsListHeader(
                isDemoMode: controller.isDemoMode,
                demoBadgeLabel: l10n.demoModeBadge,
              );
            }

            if (index <= contacts.length) {
              final contact = contacts[index - 1];
              return WearContactCard(
                contact: contact,
                onTap: () => _openBarcodePage(context, contact),
              );
            }

            return WearContactsListFooter(
              isDemoMode: controller.isDemoMode,
              openOnPhoneLabel: l10n.openOnPhone,
              authActionLabel: controller.isDemoMode ? l10n.exitDemo : l10n.logout,
              onOpenOnPhone: controller.launchPhoneApp,
              onAuthAction: controller.isDemoMode
                  ? () => _confirmExitDemo(context, controller)
                  : () => _confirmSignOut(context),
            );
          },
        ),
      ),
    );
  }
}
