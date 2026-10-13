import 'dart:async';

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/testing/fake_auth_service.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/contact_card_image_service.dart';
import 'package:tax_code_flutter/services/contact_pdf_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';
import 'package:tax_code_flutter/widgets/barcode_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/contact_card.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_empty_state.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_fab.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_search_bar.dart';
import 'package:tax_code_flutter/widgets/previews/preview_fakes.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';
import 'package:tax_code_flutter/widgets/share/share_contact_bottom_sheet.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Contact> _allContacts = TestContactFixtures.sampleContacts;

  late List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
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
      PreviewShell.showFeedback(this.context, l10n.actionLabel(l10n.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreviewShell(
      maxWidth: 600,
      padding: EdgeInsets.zero,
      expandChild: true,
      initialDarkMode: widget.isDarkMode,
      initialLocale: widget.locale,
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: FakeAuthService.authenticated(),
        ),
        Provider<SharingService>.value(
          value: const FakeSharingService(),
        ),
        Provider<ContactCardImageService>.value(
          value: const ContactCardImageService(),
        ),
        Provider<ContactPdfService>.value(
          value: const ContactPdfService(),
        ),
      ],
      builder: (context, _) {
        final l10n = context.l10n;
        final displayedContacts = _filteredContacts;

        return Scaffold(
          appBar: DashboardHeader(
            onThemeToggle: () {},
            onProfileTap: () =>
                PreviewShell.showFeedback(context, l10n.profilePageTitle),
            onSyncToggle: () =>
                PreviewShell.showFeedback(context, l10n.cloudSyncOn),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: ResponsiveLayout(
              maxWidth: 600.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Search Bar with real-time query filtering & card counter
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: DashboardSearchBar(
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
                              PreviewShell.showFeedback(context, l10n.appName);
                            },
                          )
                        : ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
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
                                onEdit: () => PreviewShell.showFeedback(
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
          ),
          floatingActionButton: _contacts.isNotEmpty
              ? DashboardFab(
                  onPressed: () {
                    PreviewShell.showFeedback(context, l10n.addCode);
                  },
                )
              : null,
        );
      },
    );
  }
}
