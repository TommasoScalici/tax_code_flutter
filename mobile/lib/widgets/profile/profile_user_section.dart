import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/services/sync_service.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
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
      padding: AppSpacing.paddingCard,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadii.borderCard,
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
                    width: AppDimensions.avatarLg,
                    height: AppDimensions.avatarLg,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: isDark ? AppOpacity.subtleBorder : 0.35,
                        ),
                        width: AppDimensions.borderSelected,
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
                      width: AppDimensions.iconXs,
                      height: AppDimensions.iconXs,
                      decoration: BoxDecoration(
                        color: isGuest
                            ? AppColors.warning
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surfaceContainer,
                          width: AppDimensions.progressStrokeWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),

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
                        const SizedBox(width: AppSpacing.xs),
                        // Badge Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: isGuest
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primaryContainer,
                            borderRadius: AppRadii.borderInner,
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
                      const SizedBox(height: AppSpacing.xxs),
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

          const SizedBox(height: AppSpacing.lg),

          // Cloud Sync Pill OR Guest Promo Upgrade
          if (!isGuest)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.fieldVertical,
                vertical: AppSpacing.compact,
              ),
              decoration: BoxDecoration(
                color: isSyncActive
                    ? theme.colorScheme.primaryContainer.withValues(
                        alpha: isDark ? 0.3 : 0.5,
                      )
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: AppRadii.borderInput,
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
                    size: AppDimensions.iconAction,
                    color: isSyncActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.compact),
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
                                  .withValues(alpha: AppOpacity.medium),
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
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: isDark ? AppOpacity.semiTranslucent : AppOpacity.divider,
                ),
                borderRadius: AppRadii.borderMd,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(
                    alpha: isDark ? AppOpacity.subtleBorder : AppOpacity.translucent,
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
                        size: AppDimensions.iconMd,
                      ),
                      const SizedBox(width: AppSpacing.sm),
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
                  const SizedBox(height: AppSpacing.badgeGap),
                  Text(
                    l10n.cloudBackupBannerSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightCompact,
                    child: FilledButton.icon(
                      key: const Key('profile_guest_google_signin_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.borderInner,
                        ),
                      ),
                      onPressed: () => authService?.signInWithGoogle(),
                      icon: SvgPicture.asset(
                        'assets/images/google_logo.svg',
                        width: AppDimensions.iconAction,
                        height: AppDimensions.iconAction,
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
