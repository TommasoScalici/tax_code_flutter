import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sub-view displaying application brand, version, package info, and terms.
class ProfileAppInfoView extends StatelessWidget {
  const ProfileAppInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final infoService = context.read<InfoServiceAbstract?>();

    if (infoService == null) {
      return Center(
        child: Text(l10n?.genericError ?? 'Errore'),
      );
    }

    return FutureBuilder<List<Object>>(
      future: Future.wait([
        infoService.getPackageInfo(),
        infoService.getLocalizedTerms(locale),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.length < 2) {
          return Center(
            child: Text(
              l10n?.genericError ?? 'Errore nel caricamento informazioni',
            ),
          );
        }

        final packageInfo = snapshot.data![0] as PackageInfo;
        final termsHtml = snapshot.data![1] as String;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. App Header Card
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
                      packageInfo.appName.isEmpty
                          ? (l10n?.appTitle ?? 'Codice Fiscale')
                          : packageInfo.appName,
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
                      packageInfo.packageName,
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

              // 2. Terms & Privacy Section
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
                          Icons.gavel_rounded,
                          size: 18,
                          color: AppColors.emeraldPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.termsAndPrivacyTitle ?? 'Termini e Privacy',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: HtmlWidget(
                          termsHtml,
                          textStyle: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.85),
                            height: 1.4,
                          ),
                          onTapUrl: (url) async {
                            final uri = Uri.tryParse(url);
                            if (uri != null) {
                              await launchUrl(uri);
                            }
                            return true;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Developer Attribution
              Center(
                child: Text(
                  l10n?.developedBy ?? 'Sviluppata da Tommaso Scalici',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
