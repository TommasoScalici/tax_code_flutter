import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/review_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/services/deep_link_service.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/widgets/contacts_list.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/profile_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

final class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DeepLinkService? _deepLinkService;
  HomePageController? _homeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingDeepLink();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDeepLinkService = context.read<DeepLinkService?>();
    if (newDeepLinkService != _deepLinkService) {
      _deepLinkService?.removeListener(_onDeepLinkChanged);
      _deepLinkService = newDeepLinkService;
      _deepLinkService?.addListener(_onDeepLinkChanged);
    }

    final newHomeController = context.read<HomePageController?>();
    if (newHomeController != _homeController) {
      _homeController?.removeListener(_onControllerChanged);
      _homeController = newHomeController;
      _homeController?.addListener(_onControllerChanged);
    }
  }

  void _onDeepLinkChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingDeepLink();
    });
  }

  void _onControllerChanged() {
    if (_homeController?.isLoading == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPendingDeepLink();
      });
    }
  }

  void _checkPendingDeepLink() {
    if (!mounted) return;
    final controller = _homeController ?? context.read<HomePageController?>();
    final deepLinkService =
        _deepLinkService ?? context.read<DeepLinkService?>();

    if (controller == null || deepLinkService == null) return;
    if (controller.isLoading) return;
    if (deepLinkService.pendingDeepLink == null) return;

    final uri = deepLinkService.consumePendingDeepLink();
    if (uri != null) {
      final authService = context.read<AuthService?>();
      unawaited(
        controller.handleBarcodeDeepLink(
          context,
          uri,
          userDisplayName: authService?.currentUser?.displayName,
        ),
      );
    }
  }

  @override
  void dispose() {
    _deepLinkService?.removeListener(_onDeepLinkChanged);
    _homeController?.removeListener(_onControllerChanged);
    super.dispose();
  }

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
    final l10n = context.l10n;

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
                content: Text(l10n.cloudSyncGuestTooltip),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          await syncService?.toggleSync();
        },
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ResponsiveLayout(
          maxWidth: AppDimensions.maxDashboardWidth,
          padding: AppSpacing.screenMargin,
          child: ContactsList(onAddContact: () => _onAddContact(context)),
        ),
      ),
      floatingActionButton:
          context.watch<HomePageController?>()?.hasContacts == true
          ? DashboardFab(onPressed: () => _onAddContact(context))
          : null,
    );
  }
}
