import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'profile_action_tile.dart';

/// The data export and Play Store rating actions section.
class ProfileDataSection extends StatelessWidget {
  const ProfileDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inAppReviewService = context.watch<InAppReviewService?>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: l10n?.sectionDataAndUtilities.toUpperCase() ??
              'DATI E FUNZIONI',
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              ProfileActionTile(
                key: const Key('profile_export_codes_tile'),
                icon: Icons.file_download_outlined,
                iconColor: AppColors.emeraldPrimary,
                iconBgColor: theme.colorScheme.surfaceContainerHigh,
                title: l10n?.exportDataTitle ?? 'Esporta codici',
                subtitle: l10n?.exportDataSubtitle ??
                    'Backup offline in formato JSON o CSV',
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.featureComingSoon ?? 'Funzionalità in arrivo',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const ProfileCardDivider(),
              ProfileActionTile(
                key: const Key('profile_rate_app_tile'),
                icon: Icons.star_rounded,
                iconColor: AppColors.starGold,
                iconBgColor: theme.colorScheme.surfaceContainerHigh,
                title: l10n?.rateAppTitle ?? 'Valuta sul Play Store',
                subtitle: l10n?.rateAppSubtitle ??
                    "Supporta lo sviluppo dell'app",
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () {
                  unawaited(inAppReviewService?.openStoreListing());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
