import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

/// Lightweight mock of [AuthService] for [DashboardHeaderPreview].
class _HeaderPreviewAuthService extends ChangeNotifier implements AuthService {
  final bool _signedIn;
  final bool _guest;

  _HeaderPreviewAuthService({bool signedIn = true, bool guest = false})
      : _signedIn = signedIn,
        _guest = guest;

  @override
  AuthStatus get status =>
      _signedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;

  @override
  User? get currentUser => null;

  @override
  bool get isSignedIn => _signedIn;

  @override
  bool get isGuest => _guest;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  String? get errorKey => null;

  @override
  AppFailure? get failure => null;

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

/// Standalone preview for [DashboardHeader] within a centered mobile viewport.
class DashboardHeaderPreview extends StatefulWidget {
  @Preview(name: 'Dashboard Header')
  const DashboardHeaderPreview({super.key});

  @override
  State<DashboardHeaderPreview> createState() => _DashboardHeaderPreviewState();
}

class _DashboardHeaderPreviewState extends State<DashboardHeaderPreview> {
  bool _isGuestMode = false;
  bool _cloudSyncEnabled = true;

  @override
  Widget build(BuildContext context) {
    final fakeAuthService = _HeaderPreviewAuthService(
      guest: _isGuestMode,
    );

    return PreviewShell(
      toolbarActions: (context, _) {
        final l10n = context.l10n;
        return [
          ChoiceChip(
            label: const Text('Google Account'),
            selected: !_isGuestMode,
            onSelected: (val) {
              if (val) setState(() => _isGuestMode = false);
            },
          ),
          ChoiceChip(
            label: Text(l10n.guestBadge),
            selected: _isGuestMode,
            onSelected: (val) {
              if (val) setState(() => _isGuestMode = true);
            },
          ),
          FilterChip(
            avatar: Icon(
              _isGuestMode
                  ? Icons.cloud_off_rounded
                  : (_cloudSyncEnabled
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded),
              size: AppDimensions.iconXs,
            ),
            label: Text(
              _isGuestMode
                  ? 'Sync Disabilitata'
                  : (_cloudSyncEnabled ? 'Cloud Sync: ON' : 'Cloud Sync: OFF'),
            ),
            selected: !_isGuestMode && _cloudSyncEnabled,
            onSelected: _isGuestMode
                ? null
                : (val) => setState(() => _cloudSyncEnabled = val),
          ),
        ];
      },
      builder: (context, isDarkMode) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final l10n = context.l10n;

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              AppColors.shadowElevated(isDarkMode),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ChangeNotifierProvider<AuthService>.value(
            value: fakeAuthService,
            child: DashboardHeader(
              isSyncActive: !_isGuestMode && _cloudSyncEnabled,
              onSyncToggle: () {
                if (!_isGuestMode) {
                  setState(() => _cloudSyncEnabled = !_cloudSyncEnabled);
                }
              },
              onThemeToggle: () => PreviewShell.showFeedback(
                context,
                l10n.themeLight,
              ),
              onProfileTap: () => PreviewShell.showFeedback(
                context,
                l10n.profilePageTitle,
              ),
            ),
          ),
        );
      },
    );
  }
}
