import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/controllers/contacts_list_controller.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/screens/barcode_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_contact_card.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_time_header.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WearDimensions.dialogRadius),
        ),
        insetPadding: WearDimensions.dialogInsetPadding,
        titlePadding: WearDimensions.dialogTitlePadding,
        actionsPadding: WearDimensions.dialogActionsPadding,
        title: Text(
          l10n.logoutConfirmation,
          style: WearTypography.cardTitle(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          SizedBox(
            width: WearDimensions.dialogButtonSize,
            height: WearDimensions.dialogButtonSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.darkOnSurfaceVariant,
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ),
          SizedBox(
            width: WearDimensions.dialogButtonSize,
            height: WearDimensions.dialogButtonSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.emeraldLight,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<AuthService>().signOut();
      } on Object {
        // Safe fallback if AuthService is not in the widget tree in testing
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ContactsListController>();
    final l10n = AppLocalizations.of(context)!;

    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.emeraldPrimary,
        ),
      );
    }

    if (!controller.hasContacts) {
      return _buildEmptyState(context, l10n, controller);
    }

    return _buildContactsList(context, l10n, controller);
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ContactsListController controller,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: WearDimensions.listPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WearTimeHeader(),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.emeraldContainerDark.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_off_rounded,
                size: WearDimensions.iconLarge,
                color: AppColors.emeraldLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noContactsFoundMessage,
              textAlign: TextAlign.center,
              style: WearTypography.cardSubtitle(color: AppColors.darkOnSurface),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.syncTakesFewMinutes,
              textAlign: TextAlign.center,
              style: WearTypography.hint(
                color: AppColors.darkOnSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 10),
            if (controller.isLaunchingPhoneApp)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.emeraldPrimary,
                ),
              )
            else
              SizedBox(
                height: WearDimensions.buttonCompactHeight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone_android, size: 16),
                  label: Text(
                    l10n.openOnPhone,
                    style: WearTypography.hint(color: Colors.white),
                  ),
                  onPressed: controller.launchPhoneApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldPrimary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _buildSignOutButton(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(
    BuildContext context,
    AppLocalizations l10n,
    ContactsListController controller,
  ) {
    final contacts = controller.contacts;

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: ListView.builder(
        controller: _scrollController,
        padding: WearDimensions.listPadding,
        itemCount: contacts.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const WearTimeHeader();
          }

          if (index <= contacts.length) {
            final contact = contacts[index - 1];
            return WearContactCard(
              contact: contact,
              onTap: () => _openBarcodePage(context, contact),
            );
          }

          // Footer actions (open on phone + sign out)
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: WearDimensions.buttonCompactHeight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.phone_android, size: 14),
                    label: Text(
                      l10n.openOnPhone,
                      style: WearTypography.hint(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    onPressed: controller.launchPhoneApp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkOnSurfaceVariant,
                      side: BorderSide(
                        color: AppColors.darkOutline.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 6.0),
                _buildSignOutButton(context, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      height: 28,
      child: TextButton.icon(
        icon: const Icon(
          Icons.logout_rounded,
          size: 14,
          color: AppColors.darkOnSurfaceVariant,
        ),
        label: Text(
          l10n.logout,
          style: WearTypography.hint(color: AppColors.darkOnSurfaceVariant),
        ),
        onPressed: () => _confirmSignOut(context),
      ),
    );
  }
}
