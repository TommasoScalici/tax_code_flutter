import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'profile_action_tile.dart';

/// The legal information and app info entry section.
class ProfileLegalSection extends StatelessWidget {
  /// Callback executed to transition into the App Info sub-view.
  final VoidCallback onOpenAppInfo;

  const ProfileLegalSection({
    required this.onOpenAppInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final infoService = context.watch<InfoServiceAbstract?>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: l10n?.sectionLegalAndAppInfo.toUpperCase() ??
              'INFORMAZIONI LEGALI',
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: FutureBuilder<PackageInfo>(
            future: infoService?.getPackageInfo() ??
                Future.value(
                  PackageInfo(
                    appName: 'Codice Fiscale',
                    packageName: 'it.scalici.tax_code_flutter',
                    version: '2.0.0',
                    buildNumber: '1',
                  ),
                ),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '2.0.0';
              return ProfileActionTile(
                key: const Key('profile_app_info_tile'),
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.info,
                iconBgColor: theme.colorScheme.surfaceContainerHigh,
                title: l10n?.appInfoTitle ?? "Informazioni sull'app",
                subtitle: l10n?.appInfoSubtitle(version) ??
                    'Versione $version • Note legali e Privacy Policy',
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: onOpenAppInfo,
              );
            },
          ),
        ),
      ],
    );
  }
}
