import 'package:flutter/material.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'profile/profile_account_section.dart';
import 'profile/profile_app_info_view.dart';
import 'profile/profile_data_section.dart';
import 'profile/profile_legal_section.dart';
import 'profile/profile_user_section.dart';

/// The view mode inside the profile bottom sheet.
enum _ProfileSheetView {
  /// Main view with user card, utilities, legal links, and account management.
  main,

  /// Sub-view displaying modern app info, package details, and terms.
  appInfo,
}

/// A modern, modular Modal Bottom Sheet for user profile management,
/// cloud sync status, offline utilities, and legal documentation.
///
/// Adheres strictly to the Stitch Design System and SOLID principles.
class ProfileBottomSheet extends StatefulWidget {
  /// When true, renders without modal decoration or drag handle for testing.
  final bool isEmbedded;

  const ProfileBottomSheet({
    super.key,
    this.isEmbedded = false,
  });

  /// Displays the profile bottom sheet modally.
  static Future<T?> show<T>(BuildContext context) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black54,
      builder: (context) => const ProfileBottomSheet(),
    );
  }

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  _ProfileSheetView _currentView = _ProfileSheetView.main;

  void _navigateToAppInfo() {
    setState(() {
      _currentView = _ProfileSheetView.appInfo;
    });
  }

  void _navigateBackToMain() {
    setState(() {
      _currentView = _ProfileSheetView.main;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: _currentView == _ProfileSheetView.main,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentView == _ProfileSheetView.appInfo) {
          _navigateBackToMain();
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer
                  : theme.colorScheme.surface,
              borderRadius: widget.isEmbedded
                  ? BorderRadius.circular(24.0)
                  : const BorderRadius.vertical(top: Radius.circular(28.0)),
              border: isDark
                  ? Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                      width: 1,
                    )
                  : null,
              boxShadow: widget.isEmbedded
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 32,
                        offset: const Offset(0, -4),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Drag Handle
                if (!widget.isEmbedded)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),

                // 2. Dynamic Header
                _buildHeader(theme, l10n),

                // 3. Dynamic Body View
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _currentView == _ProfileSheetView.main
                        ? _buildMainListView()
                        : const ProfileAppInfoView(
                            key: ValueKey('profile_app_info_view'),
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

  Widget _buildHeader(ThemeData theme, AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 12.0, 12.0),
      child: Row(
        children: [
          if (_currentView == _ProfileSheetView.appInfo)
            IconButton(
              key: const Key('profile_sheet_back_button'),
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _navigateBackToMain,
            )
          else if (widget.isEmbedded)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          Expanded(
            child: Text(
              _currentView == _ProfileSheetView.main
                  ? (l10n?.accountAndSettings ?? 'Account & Impostazioni')
                  : (l10n?.appInfoTitle ?? "Informazioni sull'app"),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (!widget.isEmbedded)
            IconButton(
              key: const Key('profile_sheet_close_button'),
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainListView() {
    return SingleChildScrollView(
      key: const ValueKey('profile_main_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: User Profile & Sync
          const ProfileUserSection(),
          const SizedBox(height: 20),

          // Section 2: Data & Utilities
          const ProfileDataSection(),
          const SizedBox(height: 20),

          // Section 3: Legal & Info
          ProfileLegalSection(onOpenAppInfo: _navigateToAppInfo),
          const SizedBox(height: 20),

          // Section 4: Account Management & GDPR
          const ProfileAccountSection(),
        ],
      ),
    );
  }
}
