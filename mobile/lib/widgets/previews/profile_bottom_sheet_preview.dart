import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widget_previews.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/controllers/profile_screen_controller.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/widgets/profile_bottom_sheet.dart';

class _PreviewAuthService extends ChangeNotifier implements AuthService {
  bool _guest;

  _PreviewAuthService({bool guest = false}) : _guest = guest;

  void setGuest(bool value) {
    _guest = value;
    notifyListeners();
  }

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  User? get currentUser => null;

  @override
  bool get isSignedIn => !_guest;

  @override
  bool get isGuest => _guest;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  String? get errorKey => null;

  @override
  Future<void> deleteUserAccount() async {}

  @override
  Future<bool> reauthenticateWithGoogle() async => true;

  @override
  Future<bool> signInWithGoogle() async {
    _guest = false;
    notifyListeners();
    return true;
  }

  @override
  Future<void> signInWithGoogleForWearable() async {}

  @override
  Future<bool> signInAnonymously() async => true;

  @override
  Future<void> signOut() async {
    _guest = true;
    notifyListeners();
  }
}

class _PreviewSyncService extends ChangeNotifier implements SyncService {
  bool _enabled = true;

  @override
  bool get isSyncEnabled => _enabled;

  @override
  bool get isUserSyncEnabled => _enabled;

  @override
  bool get canSync => true;

  @override
  Future<void> init() async {}

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    _enabled = enabled;
    notifyListeners();
  }

  @override
  Future<void> toggleSync() async {
    _enabled = !_enabled;
    notifyListeners();
  }
}

class _PreviewHomePageController extends ChangeNotifier
    implements HomePageController {
  List<Contact> get contacts => [
        Contact(
          id: '1',
          firstName: 'Mario',
          lastName: 'Rossi',
          gender: 'M',
          birthDate: DateTime(1985, 4, 15),
          birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
          taxCode: 'RSSMRA85D15H501Z',
          listIndex: 0,
        ),
        Contact(
          id: '2',
          firstName: 'Laura',
          lastName: 'Neri',
          gender: 'F',
          birthDate: DateTime(1992, 8, 24),
          birthPlace:
              const Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
          taxCode: 'NREBNC92M64F205K',
          listIndex: 1,
        ),
        Contact(
          id: '3',
          firstName: 'Giuseppe',
          lastName: 'Verdi',
          gender: 'M',
          birthDate: DateTime(1978, 11, 2),
          birthPlace:
              const Birthplace(name: 'Napoli', state: 'NA', code: 'F839'),
          taxCode: 'VRDGPP78S02F839T',
          listIndex: 2,
        ),
      ];

  @override
  List<Contact> get contactsToShow => contacts;

  @override
  bool get hasContacts => true;

  @override
  bool get isLoading => false;

  bool get isReordering => false;

  @override
  bool get isReorderable => true;

  @override
  String get searchText => '';

  @override
  void filterContacts(String text) {}

  @override
  void shareContact(Contact contact) {}

  @override
  Future<void> saveContact(Contact contact) async {}

  @override
  Future<void> deleteContact(Contact contact) async {}

  @override
  Future<void> reorderContacts(int oldIndex, int newIndex) async {}

  void toggleReordering() {}
}

class _PreviewInfoService implements InfoServiceAbstract {
  @override
  Future<PackageInfo> getPackageInfo() async {
    return PackageInfo(
      appName: 'Codice Fiscale',
      packageName: 'tommasoscalici.taxcode',
      version: '2.0.0',
      buildNumber: '1',
      installerStore: 'Google Play',
    );
  }
}

class _PreviewInAppReviewService implements InAppReviewService {
  @override
  Future<void> openStoreListing() async {}

  @override
  Future<void> maybeRequestReview() async {}
}

/// Standalone interactive preview for [ProfileBottomSheet].
class ProfileBottomSheetPreview extends StatefulWidget {
  @Preview(name: 'Profile & Settings Bottom Sheet')
  const ProfileBottomSheetPreview({super.key});

  @override
  State<ProfileBottomSheetPreview> createState() =>
      _ProfileBottomSheetPreviewState();
}

class _ProfileBottomSheetPreviewState extends State<ProfileBottomSheetPreview> {
  bool _isDarkMode = true;
  bool _isGuestMode = false;

  late final _PreviewAuthService _authService;
  late final _PreviewSyncService _syncService;
  late final _PreviewHomePageController _homeController;
  late final _PreviewInfoService _infoService;
  late final _PreviewInAppReviewService _inAppReviewService;
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    _authService = _PreviewAuthService(guest: _isGuestMode);
    _syncService = _PreviewSyncService();
    _homeController = _PreviewHomePageController();
    _infoService = _PreviewInfoService();
    _inAppReviewService = _PreviewInAppReviewService();
    _logger = Logger();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<SyncService>.value(value: _syncService),
        ChangeNotifierProvider<HomePageController>.value(value: _homeController),
        Provider<InfoServiceAbstract>.value(value: _infoService),
        Provider<InAppReviewService>.value(value: _inAppReviewService),
        Provider<Logger>.value(value: _logger),
        ChangeNotifierProvider<ProfileScreenController>(
          create: (_) => ProfileScreenController(
            authService: _authService,
            logger: _logger,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Preview Toolbar Controls
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  color: _isDarkMode
                      ? AppColors.darkSurfaceContainerLowest
                      : AppColors.lightSurfaceContainerLow,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Theme Switch
                      ActionChip(
                        avatar: Icon(
                          _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          size: 16,
                        ),
                        label: Text(_isDarkMode ? 'Dark Mode' : 'Light Mode'),
                        onPressed: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                      ),

                      // User Mode Switch
                      FilterChip(
                        label: Text(_isGuestMode ? 'Ospite (Guest)' : 'Google (Mario Rossi)'),
                        selected: _isGuestMode,
                        onSelected: (val) {
                          setState(() {
                            _isGuestMode = val;
                            _authService.setGuest(val);
                          });
                        },
                      ),

                      // Open Modal Bottom Sheet button
                      Builder(
                        builder: (btnContext) => FilledButton.icon(
                          icon: const Icon(Icons.open_in_browser, size: 16),
                          label: const Text('Apri come Bottom Sheet'),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            unawaited(ProfileBottomSheet.show(btnContext));
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Embedded Sheet Viewport
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 412.0,
                      ),
                      child: const ProfileBottomSheet(isEmbedded: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
