import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:shared/testing/fake_auth_service.dart';
import 'package:shared/testing/fake_sync_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/controllers/profile_screen_controller.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';
import 'package:tax_code_flutter/widgets/profile_bottom_sheet.dart';

/// Standalone interactive preview for [ProfileBottomSheet].
class ProfileBottomSheetPreview extends StatefulWidget {
  @Preview(name: 'Profile & Settings Bottom Sheet')
  const ProfileBottomSheetPreview({super.key});

  @override
  State<ProfileBottomSheetPreview> createState() =>
      _ProfileBottomSheetPreviewState();
}

class _ProfileBottomSheetPreviewState extends State<ProfileBottomSheetPreview> {
  bool _isGuestMode = false;

  late final FakeAuthService _authService;
  late final FakeSyncService _syncService;
  late final FakeHomePageController _homeController;
  late final FakeInfoService _infoService;
  late final FakeInAppReviewService _inAppReviewService;
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    _authService = _isGuestMode
        ? FakeAuthService.guest()
        : FakeAuthService.authenticated();
    _syncService = FakeSyncService();
    _homeController = FakeHomePageController();
    _infoService = FakeInfoService();
    _inAppReviewService = FakeInAppReviewService();
    _logger = Logger();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      expandChild: true,
      padding: EdgeInsets.zero,
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<SyncService>.value(value: _syncService),
        ChangeNotifierProvider<HomePageController>.value(
          value: _homeController,
        ),
        Provider<InfoService>.value(value: _infoService),
        Provider<InAppReviewService>.value(value: _inAppReviewService),
        Provider<Logger>.value(value: _logger),
        ChangeNotifierProvider<ProfileScreenController>(
          create: (_) => ProfileScreenController(
            authService: _authService,
            logger: _logger,
          ),
        ),
      ],
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          FilterChip(
            label: Text(
              _isGuestMode ? l10n.guestBadge : 'Google (Mario Rossi)',
            ),
            selected: _isGuestMode,
            onSelected: (val) {
              setState(() {
                _isGuestMode = val;
                _authService.setGuest(val);
              });
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_browser, size: 16),
            label: Text(l10n.openAsBottomSheet),
            style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
            onPressed: () {
              unawaited(ProfileBottomSheet.show(context));
            },
          ),
        ];
      },
      child: const ProfileBottomSheet(isEmbedded: true),
    );
  }
}
