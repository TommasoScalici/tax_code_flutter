import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sub-view displaying application brand, version, official disclaimer,
/// native privacy highlights, and direct link to the online privacy policy.
class ProfileAppInfoView extends StatelessWidget {
  const ProfileAppInfoView({super.key});

  static const String _privacyPolicyUrlIt =
      'https://tommasoscalici.dev/it/apps/taxcode/privacy-policy/';
  static const String _privacyPolicyUrlEn =
      'https://tommasoscalici.dev/apps/taxcode/privacy-policy/';
  static const String _developerWebsiteUrl = 'https://tommasoscalici.dev';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final infoService = context.watch<InfoServiceAbstract?>();

    final defaultPackageInfo = PackageInfo(
      appName: l10n.appName,
      packageName: 'tommasoscalici.taxcode',
      version: '2.0.0',
      buildNumber: '1',
    );

    return FutureBuilder<PackageInfo>(
      future: infoService?.getPackageInfo() ?? Future.value(defaultPackageInfo),
      builder: (context, snapshot) {
        final packageInfo = snapshot.data ?? defaultPackageInfo;
        final rawAppName = packageInfo.appName;
        final appDisplayName = (rawAppName.isEmpty || rawAppName == 'Error')
            ? l10n.appName
            : rawAppName;
        final rawPackageName = packageInfo.packageName;
        final appPackageId =
            (rawPackageName.isEmpty || rawPackageName == 'Error')
                ? 'tommasoscalici.taxcode'
                : rawPackageName;

        final policyUrl = locale.languageCode == 'it'
            ? _privacyPolicyUrlIt
            : _privacyPolicyUrlEn;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. App Header Card (Brand, Version, Package Name)
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          AppColors.shadowElevated(isDark),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/tax_code_icon.svg',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appDisplayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: isDark ? 0.25 : 0.35,
                          ),
                        ),
                      ),
                      child: Text(
                        'v${packageInfo.version} (${packageInfo.buildNumber})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appPackageId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'JetBrains Mono',
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Official Institutional Disclaimer Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: AppColors.warningBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        size: 20,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.disclaimerTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.disclaimerBody,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Native Privacy & Data Protection Highlights Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.privacyHighlightsTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildHighlightItem(
                      theme: theme,
                      icon: Icons.lock_outline_rounded,
                      title: l10n.privacyDataOwnership,
                      description: l10n.privacyDataOwnershipDesc,
                    ),
                    _buildHighlightDivider(theme),
                    _buildHighlightItem(
                      theme: theme,
                      icon: Icons.shield_outlined,
                      title: l10n.privacyNoTracking,
                      description: l10n.privacyNoTrackingDesc,
                    ),
                    _buildHighlightDivider(theme),
                    _buildHighlightItem(
                      theme: theme,
                      icon: Icons.document_scanner_outlined,
                      title: l10n.privacySmartOcr,
                      description: l10n.privacySmartOcrDesc,
                    ),
                    _buildHighlightDivider(theme),
                    _buildHighlightItem(
                      theme: theme,
                      icon: Icons.delete_sweep_outlined,
                      title: l10n.privacyGdprRights,
                      description: l10n.privacyGdprRightsDesc,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. CTA Button: Open Full Online Privacy Policy
              OutlinedButton.icon(
                key: const Key('profile_open_online_policy_button'),
                onPressed: () => _openUrl(policyUrl),
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  l10n.readFullPrivacyPolicy,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(
                    alpha: isDark ? 0.3 : 0.4,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(
                      alpha: isDark ? 0.3 : 0.4,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. Developer Attribution with Link
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: () => _openUrl(_developerWebsiteUrl),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    child: Text(
                      l10n.developedBy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Divider(
        height: 1,
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
    );
  }

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    }
  }
}
