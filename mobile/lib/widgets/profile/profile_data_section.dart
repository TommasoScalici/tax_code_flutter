import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/widgets/export/export_data_bottom_sheet.dart';
import 'package:tax_code_flutter/widgets/profile/profile_action_tile.dart';

/// The data export and Play Store rating actions section.
class ProfileDataSection extends StatelessWidget {
  const ProfileDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final inAppReviewService = context.watch<InAppReviewService?>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: l10n.sectionDataAndUtilities.toUpperCase(),
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
                iconColor: theme.colorScheme.primary,
                iconBgColor: theme.colorScheme.surfaceContainerHigh,
                title: l10n.exportDataTitle,
                subtitle: l10n.exportDataSubtitle,
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  unawaited(ExportDataBottomSheet.show(context));
                },
              ),
              const ProfileCardDivider(),
              ProfileActionTile(
                key: const Key('profile_rate_app_tile'),
                icon: Icons.star_rounded,
                iconColor: AppColors.starGold,
                iconBgColor: theme.colorScheme.surfaceContainerHigh,
                title: l10n.rateAppTitle,
                subtitle: l10n.rateAppSubtitle,
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
