import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// The user identity, cloud sync status, and guest upgrade section.
class ProfileUserSection extends StatelessWidget {
  const ProfileUserSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final authService = context.watch<AuthService?>();
    final syncService = context.watch<SyncService?>();
    final homeController = context.watch<HomePageController?>();

    final isGuest = authService?.isGuest ?? false;
    final currentUser = authService?.currentUser;
    final displayName = isGuest
        ? l10n.guestBadge
        : (currentUser?.displayName ?? l10n.contactFallback);
    final email = isGuest ? null : currentUser?.email;
    final photoURL = isGuest ? null : currentUser?.photoURL;
    final isSyncActive = !isGuest && (syncService?.isSyncEnabled ?? false);
    final savedCount = homeController?.contactsToShow.length ?? 0;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User row: Avatar + Identity
          Row(
            children: [
              // Avatar with status dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: isDark ? 0.25 : 0.35,
                        ),
                        width: 2.0,
                      ),
                    ),
                    child: ClipOval(
                      child: (photoURL != null && photoURL.isNotEmpty)
                          ? Image.network(
                              photoURL,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _buildAvatarFallback(theme, displayName),
                            )
                          : _buildAvatarFallback(theme, displayName),
                    ),
                  ),
                  // Status dot
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isGuest
                            ? AppColors.warning
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainer,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name, Email, Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: isGuest
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            isGuest ? l10n.guestBadge : l10n.googleBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isGuest
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cloud Sync Pill OR Guest Promo Upgrade
          if (!isGuest)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isSyncActive
                    ? theme.colorScheme.primaryContainer.withValues(
                        alpha: isDark ? 0.3 : 0.5,
                      )
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: isSyncActive
                      ? theme.colorScheme.primary.withValues(
                          alpha: isDark ? 0.3 : 0.4,
                        )
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSyncActive
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_queue_rounded,
                    size: 18,
                    color: isSyncActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isSyncActive
                              ? l10n.cloudSyncActive
                              : l10n.cloudSyncOff,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSyncActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isSyncActive)
                          Text(
                            ' • ${l10n.syncSavedCodesCount(savedCount)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // Guest Mode Upgrade Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: isDark ? 0.16 : 0.5,
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(
                    alpha: isDark ? 0.25 : 0.3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.cloudBackupBannerTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.cloudBackupBannerSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton.icon(
                      key: const Key('profile_guest_google_signin_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () => authService?.signInWithGoogle(),
                      icon: SvgPicture.asset(
                        'assets/images/google_logo.svg',
                        width: 18,
                        height: 18,
                      ),
                      label: Text(
                        l10n.continueWithGoogle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(ThemeData theme, String displayName) {
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandGradientStart,
            AppColors.brandGradientEnd,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.opticalWhite,
          ),
        ),
      ),
    );
  }
}
