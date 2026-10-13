import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/review_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:shared/testing/testing.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/screens/home_page.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/previews/form_screen_preview.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Full screen preview for [HomePage] ("I Miei Codici"),
/// maintaining 1:1 Screen Parity with production.
///
/// Features interactive toggles for:
/// - Light vs Dark theme
/// - English vs Italian localization
/// - With Contacts vs Empty State
/// - Authenticated User vs Guest Mode
class DashboardScreenPreview extends StatefulWidget {
  @Preview(name: 'Dashboard Screen')
  const DashboardScreenPreview({
    super.key,
    this.locale = const Locale('it'),
    this.initialContacts,
    this.isDarkMode = false,
  });

  final Locale locale;
  final List<Contact>? initialContacts;
  final bool isDarkMode;

  @override
  State<DashboardScreenPreview> createState() => _DashboardScreenPreviewState();
}

class _DashboardScreenPreviewState extends State<DashboardScreenPreview> {
  late final FakeHomePageController _controller;
  late final FakeSyncService _syncService;
  late final FakeAuthService _authService;
  late final FakeContactRepository _contactRepository;
  late final FakeReviewService _reviewService;
  late final FakeInAppReviewService _inAppReviewService;

  @override
  void initState() {
    super.initState();
    final contacts =
        widget.initialContacts ?? TestContactFixtures.sampleContacts;
    _controller = FakeHomePageController(contacts);
    _syncService = FakeSyncService();
    _authService = FakeAuthService.authenticated();
    _contactRepository = FakeContactRepository(contacts);
    _reviewService = FakeReviewService();
    _inAppReviewService = FakeInAppReviewService();
  }

  @override
  void dispose() {
    _controller.dispose();
    _syncService.dispose();
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 600,
      padding: EdgeInsets.zero,
      expandChild: true,
      initialDarkMode: widget.isDarkMode,
      initialLocale: widget.locale,
      routes: {Routes.form: (context) => const FormScreenPreview()},
      providers: [
        ChangeNotifierProvider<HomePageController>.value(value: _controller),
        ChangeNotifierProvider<SyncService>.value(value: _syncService),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        Provider<ReviewService>.value(value: _reviewService),
        Provider<InAppReviewService>.value(value: _inAppReviewService),
        ChangeNotifierProvider<ContactRepository>.value(
          value: _contactRepository,
        ),
        Provider<SharingService>.value(value: const FakeSharingService()),
        Provider<BrightnessService>.value(value: FakeBrightnessService()),
        Provider<InfoService>.value(value: FakeInfoService()),
        Provider<ContactCardImageService>.value(
          value: const ContactCardImageService(),
        ),
        Provider<ContactPdfService>.value(value: const ContactPdfService()),
      ],
      toolbarActions: (context, _) => [
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => ChoiceChip(
            label: const Text('Con contatti'),
            selected: _controller.hasContacts,
            onSelected: (val) {
              if (val) {
                _controller.setContacts(TestContactFixtures.sampleContacts);
              }
            },
          ),
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => ChoiceChip(
            label: const Text('Lista vuota'),
            selected: !_controller.hasContacts,
            onSelected: (val) {
              if (val) {
                _controller.setContacts(const []);
              }
            },
          ),
        ),
        ListenableBuilder(
          listenable: _authService,
          builder: (context, _) => ChoiceChip(
            label: const Text('Ospite'),
            selected: _authService.isGuest,
            onSelected: (val) {
              if (val) {
                unawaited(_authService.signInAnonymously());
              } else {
                unawaited(_authService.signInWithGoogle());
              }
            },
          ),
        ),
      ],
      child: const HomePage(),
    );
  }
}
