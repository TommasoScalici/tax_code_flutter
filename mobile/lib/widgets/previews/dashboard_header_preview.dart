import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/testing/fake_auth_service.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/dashboard/dashboard_header.dart';
import 'package:tax_code_flutter/widgets/previews/preview_shell.dart';

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
    final fakeAuthService = _isGuestMode
        ? FakeAuthService.guest()
        : FakeAuthService.authenticated();

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
            boxShadow: [AppColors.shadowElevated(isDarkMode)],
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
              onThemeToggle: () =>
                  PreviewShell.showFeedback(context, l10n.themeLight),
              onProfileTap: () =>
                  PreviewShell.showFeedback(context, l10n.profilePageTitle),
            ),
          ),
        );
      },
    );
  }
}
