import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/review_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/widgets/contacts_list.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/profile_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _onAddContact(BuildContext context) async {
    final homeController = context.read<HomePageController>();
    final newContact =
        await Navigator.pushNamed(context, Routes.form) as Contact?;

    if (newContact != null) {
      homeController.saveContact(newContact);

      if (!context.mounted) return;
      final reviewService = context.read<ReviewService>();
      await reviewService.incrementSuccessfulCalculations();

      if (!context.mounted) return;
      final inAppReviewService = context.read<InAppReviewService>();
      await inAppReviewService.maybeRequestReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncService = context.watch<SyncService?>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: DashboardHeader(
        isSyncActive: syncService?.isSyncEnabled,
        onProfileTap: () => ProfileBottomSheet.show<void>(context),
        onSyncToggle: () async {
          final authService = context.read<AuthService?>();
          if (authService?.isGuest == true) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.cloudSyncGuestTooltip ?? ''),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          await syncService?.toggleSync();
        },
      ),
      body: ResponsiveLayout(
        maxWidth: 600.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ContactsList(
          onAddContact: () => _onAddContact(context),
        ),
      ),
      floatingActionButton: DashboardFab(
        onPressed: () => _onAddContact(context),
      ),
    );
  }
}
