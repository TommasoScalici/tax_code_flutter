import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_empty_state.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_search_bar.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

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
  const DashboardScreenPreview({super.key});

  @override
  State<DashboardScreenPreview> createState() => _DashboardScreenPreviewState();
}

class _DashboardScreenPreviewState extends State<DashboardScreenPreview> {
  bool _isDarkMode = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Contact> _allContacts = [
    Contact(
      id: '1',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      birthDate: DateTime(1980, 1, 15),
      birthPlace: const Birthplace(name: 'Roma', state: 'RM'),
      taxCode: 'RSSMRA80A15H501U',
      listIndex: 0,
    ),
    Contact(
      id: '2',
      firstName: 'Giulia',
      lastName: 'Bianchi',
      gender: 'F',
      birthDate: DateTime(1992, 5, 23),
      birthPlace: const Birthplace(name: 'Milano', state: 'MI'),
      taxCode: 'BNCGLI92E63F205Z',
      listIndex: 1,
    ),
    Contact(
      id: '3',
      firstName: 'Alessandro',
      lastName: 'Verdi',
      gender: 'M',
      birthDate: DateTime(1975, 11, 8),
      birthPlace: const Birthplace(name: 'Napoli', state: 'NA'),
      taxCode: 'VRDLSN75S08F839K',
      listIndex: 2,
    ),
  ];

  late List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(_allContacts);
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final displayedContacts = _filteredContacts;

          return ChangeNotifierProvider<AuthService>.value(
            value: _ScreenPreviewAuthService(),
            child: Scaffold(
              appBar: DashboardHeader(
                onThemeToggle: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                },
                onProfileTap: () => _showFeedback(context, l10n.profilePageTitle),
                onSyncToggle: () => _showFeedback(context, 'Cloud Sync Toggle'),
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
                            searchQuery:
                                _searchQuery.isNotEmpty ? _searchQuery : null,
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
                              _showFeedback(context, 'Codici ripristinati');
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
                                onShare: () => _showFeedback(
                                  context,
                                  'Condividi: ${contact.taxCode}',
                                ),
                                onShowBarcode: () => _showFeedback(
                                  context,
                                  'Barcode: ${contact.taxCode}',
                                ),
                                onEdit: () => _showFeedback(
                                  context,
                                  'Modifica: ${contact.firstName}',
                                ),
                                onDelete: () {
                                  setState(() {
                                    _contacts.removeWhere(
                                      (c) => c.id == contact.id,
                                    );
                                  });
                                  _showFeedback(
                                    context,
                                    'Eliminato: ${contact.firstName}',
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: DashboardFab(
              onPressed: () {
                _showFeedback(context, l10n.addCode);
              },
            ),
          ),
        );
      },
      ),
    );
  }
}
