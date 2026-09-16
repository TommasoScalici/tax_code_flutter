import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_empty_state.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_search_bar.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

class _PreviewSharingService implements SharingServiceAbstract {
  const _PreviewSharingService();

  @override
  Future<ShareResult> share({required String text}) async =>
      const ShareResult('', ShareResultStatus.success);

  @override
  Future<ShareResult> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  }) async =>
      const ShareResult('', ShareResultStatus.success);
}

class _ScreenPreviewAuthService extends ChangeNotifier implements AuthService {
  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  User? get currentUser => null;

  @override
  bool get isSignedIn => true;

  @override
  bool get isGuest => false;

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
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<void> signInWithGoogleForWearable() async {}

  @override
  Future<bool> signInAnonymously() async => true;

  @override
  Future<void> signOut() async {}
}

/// Full screen preview for the Dashboard v2 ("I Miei Codici"),
/// showcasing [DashboardHeader], [DashboardSearchBar], [ContactCard],
/// [DashboardEmptyState], and [DashboardFab] in action.
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
  late bool _isDarkMode;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Contact> _allContacts = [
    Contact(
      id: '1',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      birthDate: DateTime(1980, 1, 15),
      birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
      taxCode: 'RSSMRA80A15H501U',
      listIndex: 0,
    ),
    Contact(
      id: '2',
      firstName: 'Giulia',
      lastName: 'Bianchi',
      gender: 'F',
      birthDate: DateTime(1992, 5, 23),
      birthPlace: const Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
      taxCode: 'BNCGLI92E63F205Z',
      listIndex: 1,
    ),
    Contact(
      id: '3',
      firstName: 'Alessandro',
      lastName: 'Verdi',
      gender: 'M',
      birthDate: DateTime(1975, 11, 8),
      birthPlace: const Birthplace(name: 'Napoli', state: 'NA', code: 'F839'),
      taxCode: 'VRDLSN75S08F839K',
      listIndex: 2,
    ),
  ];

  late List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _contacts = widget.initialContacts != null
        ? List.from(widget.initialContacts!)
        : List.from(_allContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Contact> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    final q = _searchQuery.toLowerCase();
    return _contacts.where((c) {
      return c.firstName.toLowerCase().contains(q) ||
          c.lastName.toLowerCase().contains(q) ||
          c.taxCode.toLowerCase().contains(q);
    }).toList();
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, Contact contact) async {
    final l10n = context.l10n;
    final bool? isConfirmed = await showDialog<bool>(
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
            child: Text(
              l10n.delete,
              style: Theme.of(dialogContext).textTheme.labelLarge?.copyWith(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (isConfirmed == true && mounted) {
      setState(() {
        _contacts.removeWhere((c) => c.id == contact.id);
      });
      _showFeedback(this.context, l10n.actionLabel(l10n.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: _ScreenPreviewAuthService(),
        ),
        Provider<SharingServiceAbstract>.value(
          value: const _PreviewSharingService(),
        ),
        Provider<ContactCardImageServiceAbstract>.value(
          value: const ContactCardImageService(),
        ),
        Provider<ContactPdfServiceAbstract>.value(
          value: const ContactPdfService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        locale: widget.locale,
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = context.l10n;
            final displayedContacts = _filteredContacts;

            return Scaffold(
              appBar: DashboardHeader(
                onThemeToggle: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                },
                onProfileTap: () =>
                    _showFeedback(context, l10n.profilePageTitle),
                onSyncToggle: () =>
                    _showFeedback(context, l10n.cloudSyncOn),
              ),
              body: ResponsiveLayout(
                maxWidth: 600.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Search Bar with real-time query filtering & card counter
                    DashboardSearchBar(
                      controller: _searchController,
                      cardCount: _contacts.length,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    ),

                    // Content Area
                    Expanded(
                      child: displayedContacts.isEmpty
                          ? DashboardEmptyState(
                              searchQuery: _searchQuery.isNotEmpty
                                  ? _searchQuery
                                  : null,
                              onClearSearch: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              onAddContact: () {
                                setState(() {
                                  _contacts = List.from(_allContacts);
                                });
                                _showFeedback(context, l10n.appName);
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                top: 4.0,
                                bottom: 90.0,
                                left: 16.0,
                                right: 16.0,
                              ),
                              itemCount: displayedContacts.length,
                              itemBuilder: (context, index) {
                                final contact = displayedContacts[index];
                                return ContactCard(
                                  key: ValueKey(contact.id),
                                  contact: contact,
                                  onShare: () => unawaited(
                                    ShareContactBottomSheet.show(
                                      context,
                                      contact: contact,
                                    ),
                                  ),
                                  onShowBarcode: () => unawaited(
                                    BarcodeBottomSheet.show(
                                      context,
                                      contact: contact,
                                    ),
                                  ),
                                  onEdit: () => _showFeedback(
                                    context,
                                    l10n.cardActionEdit,
                                  ),
                                  onDelete: () =>
                                      _handleDelete(context, contact),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: _contacts.isNotEmpty
                  ? DashboardFab(
                      onPressed: () {
                        _showFeedback(context, l10n.addCode);
                      },
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
