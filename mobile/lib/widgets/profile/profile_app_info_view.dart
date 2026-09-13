import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final infoService = context.watch<InfoServiceAbstract?>();

    final defaultPackageInfo = PackageInfo(
      appName: l10n?.appName ?? 'Codice Fiscale',
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
            ? (l10n?.appName ?? 'Codice Fiscale')
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
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.35 : 0.08,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/images/tax_code_icon.svg',
                        fit: BoxFit.contain,
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
                        color: AppColors.emeraldContainerDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.emeraldBorder),
                      ),
                      child: Text(
                        'v${packageInfo.version} (${packageInfo.buildNumber})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.emeraldPrimary,
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
                    color: AppColors.warning.withValues(alpha: 0.35),
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
                            l10n?.disclaimerTitle ?? 'Disclaimer Istituzionale',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n?.disclaimerBody ??
                                "Questa applicazione non rappresenta né è affiliata ad alcuna agenzia governativa. È uno strumento di terze parti per calcolare e memorizzare il Codice Fiscale tramite l'algoritmo pubblico.",
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
                        const Icon(
                          Icons.security_rounded,
                          size: 20,
                          color: AppColors.emeraldPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.privacyHighlightsTitle ??
                              'Privacy & Protezione Dati',
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
                      title: l10n?.privacyDataOwnership ?? 'Dati e Proprietà',
                      description: l10n?.privacyDataOwnershipDesc ??
                          'I tuoi codici rimangono di tua proprietà, salvati sul dispositivo o nel tuo cloud cifrato.',
                    ),
                    _buildHighlightDivider(theme),
                    _buildHighlightItem(
                      theme: theme,
                      icon: Icons.shield_outlined,
                      title: l10n?.privacyNoTracking ?? 'Zero Tracciamento',
                      description: l10n?.privacyNoTrackingDesc ??
                          'Nessun dato personale viene venduto o utilizzato per profilazione commerciale.',
                    ),
                    _buildHighlightDivider(theme),
                    _buildHighlightItem(
                      theme: theme,
                      icon: Icons.document_scanner_outlined,
                      title: l10n?.privacySmartOcr ?? 'Scansione Documenti',
                      description: l10n?.privacySmartOcrDesc ??
                          "L'OCR AI per la lettura delle tessere opera con standard elevati di sicurezza.",
                    ),
                    _buildHighlightDivider(theme),
                    _buildHighlightItem(
                      theme: theme,
                      icon: Icons.delete_sweep_outlined,
                      title: l10n?.privacyGdprRights ??
                          "Diritto all'Oblio (GDPR)",
                      description: l10n?.privacyGdprRightsDesc ??
                          'Puoi esportare o eliminare definitivamente il tuo account e i dati in qualsiasi momento.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. CTA Button: Open Full Online Privacy Policy
              OutlinedButton.icon(
                key: const Key('profile_open_online_policy_button'),
                onPressed: () => _openUrl(policyUrl),
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: AppColors.emeraldPrimary,
                ),
                label: Text(
                  l10n?.readFullPrivacyPolicy ??
                      "Leggi l'Informativa Completa Online",
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.emeraldContainerDark,
                  side: const BorderSide(color: AppColors.emeraldBorder),
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
                      l10n?.developedBy ?? 'Sviluppata da Tommaso Scalici',
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
          color: AppColors.emeraldPrimary,
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
