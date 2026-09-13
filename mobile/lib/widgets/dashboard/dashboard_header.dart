import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/theme_service.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/l10n/app_localizations_it.dart';
import 'package:tax_code_flutter/widgets/user_avatar.dart';

/// The top app bar header for the Dashboard following the Emerald Ledger design system.
///
/// Features:
/// - Brand icon (`tax_code_icon.svg`) with uppercase subtitle ("CODICE FISCALE")
///   and headline ("I Miei Codici").
/// - Round theme toggle button (light/dark mode).
/// - User profile avatar with active cloud sync indicator badge.
class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Optional callback when tapping the theme toggle button.
  /// If omitted, defaults to [ThemeService.toggleTheme].
  final VoidCallback? onThemeToggle;

  /// Optional callback when tapping the user profile avatar.
  final VoidCallback? onProfileTap;

  /// Optional callback when tapping the cloud sync action button.
  final VoidCallback? onSyncToggle;

  /// Optional custom title. Defaults to localized [AppLocalizations.dashboardTitle].
  final String? title;

  /// Optional custom subtitle. Defaults to localized [AppLocalizations.appTitle].
  final String? subtitle;

  /// Whether cloud sync is active.
  /// If null, automatically reflects whether the user is signed in and not in guest mode.
  final bool? isSyncActive;

  /// Backward-compatible alias for [isSyncActive].
  final bool? showSyncBadge;

  const DashboardHeader({
    super.key,
    this.onThemeToggle,
    this.onProfileTap,
    this.onSyncToggle,
    this.title,
    this.subtitle,
    this.isSyncActive,
    this.showSyncBadge,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
    final isDark = theme.brightness == Brightness.dark;

    final authService = context.watch<AuthService?>();
    var isGuest = false;
    var isSignedIn = false;
    try {
      isGuest = authService?.isGuest ?? false;
      isSignedIn = authService?.isSignedIn ?? false;
    } on Object catch (_) {}

    // Determine whether sync is active (defaults to authenticated Google user)
    final syncActive = isSyncActive ??
        (showSyncBadge ?? (isSignedIn && !isGuest));

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16.0,
      backgroundColor: colorScheme.surface.withValues(alpha: isDark ? 0.85 : 0.90),
      elevation: 0,
      scrolledUnderElevation: 2,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Brand Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: SvgPicture.asset(
                'assets/images/tax_code_icon.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (subtitle ?? l10n.appTitle).toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title ?? l10n.dashboardTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Cloud Sync Action Button
        _buildSyncButton(
          context: context,
          isGuest: isGuest,
          isSyncActive: syncActive,
          colorScheme: colorScheme,
          l10n: l10n,
        ),

        // Theme Switch Action
        IconButton(
          key: const Key('dashboard_header_theme_button'),
          tooltip: l10n.switchTheme,
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 22,
          ),
          onPressed: () {
            if (onThemeToggle != null) {
              onThemeToggle!();
            } else {
              context.read<ThemeService?>()?.toggleTheme();
            }
          },
        ),

        // Profile Avatar Action with Cloud Sync Badge
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 12.0),
          child: Tooltip(
            message: syncActive ? l10n.cloudSyncActive : l10n.profilePageTitle,
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const UserAvatar(size: 34),
                  if (syncActive)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        key: const Key('dashboard_header_sync_badge'),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.syncPulse,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.syncPulse.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncButton({
    required BuildContext context,
    required bool isGuest,
    required bool isSyncActive,
    required ColorScheme colorScheme,
    required AppLocalizations l10n,
  }) {
    if (isGuest) {
      // Disabled state for guest users
      return IconButton(
        key: const Key('dashboard_header_sync_button'),
        tooltip: l10n.cloudSyncGuestTooltip,
        icon: Icon(
          Icons.cloud_off_rounded,
          color: colorScheme.onSurface.withValues(alpha: 0.38),
          size: 22,
        ),
        onPressed: () {
          // Provide clear feedback explaining why sync is disabled for guests
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cloudSyncGuestTooltip),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          onSyncToggle?.call();
        },
      );
    }

    // Authenticated user state
    final syncIcon =
        isSyncActive ? Icons.cloud_done_rounded : Icons.cloud_off_rounded;
    final syncColor =
        isSyncActive ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final tooltipMessage =
        isSyncActive ? l10n.cloudSyncOn : l10n.cloudSyncOff;

    return IconButton(
      key: const Key('dashboard_header_sync_button'),
      tooltip: tooltipMessage,
      icon: Icon(
        syncIcon,
        color: syncColor,
        size: 22,
      ),
      onPressed: () {
        if (onSyncToggle != null) {
          onSyncToggle!();
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tooltipMessage),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}
