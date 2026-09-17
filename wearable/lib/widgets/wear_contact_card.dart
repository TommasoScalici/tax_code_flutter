import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';

/// A compact, high-contrast contact card tailored for Wear OS circular displays.
///
/// Features:
/// - Prominent contact full name.
/// - Emerald-accented monospace pill for the Italian Tax Code (Codice Fiscale).
/// - Secondary birth place and formatted birth date.
/// - Clear touch feedback with subtle barcode/QR hint icon.
class WearContactCard extends StatelessWidget {
  const WearContactCard({
    required this.contact,
    required this.onTap,
    super.key,
  });

  final Contact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final birthDateStr = DateFormat.yMd().format(contact.birthDate);
    final birthPlaceStr = contact.birthPlace.name.isNotEmpty
        ? (contact.birthPlace.state.isNotEmpty
            ? '${contact.birthPlace.name} (${contact.birthPlace.state})'
            : contact.birthPlace.name)
        : '';
    final metadataStr = [
      if (birthDateStr.isNotEmpty) birthDateStr,
      if (birthPlaceStr.isNotEmpty) birthPlaceStr,
    ].join(' • ');

    final fullName = '${contact.firstName} ${contact.lastName}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : contact.taxCode;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: WearDimensions.cardSpacing / 2,
      ),
      elevation: 0,
      color: AppColors.darkSurfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WearDimensions.cardRadius),
        side: BorderSide(
          color: AppColors.darkOutline.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WearDimensions.cardRadius),
        splashColor: AppColors.emeraldPrimary.withValues(alpha: 0.15),
        highlightColor: AppColors.emeraldPrimary.withValues(alpha: 0.08),
        child: Padding(
          padding: WearDimensions.cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contact Name
              Text(
                displayName,
                style: WearTypography.cardTitle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),

              // Tax Code Monospace Pill with QR hint
              Container(
                padding: WearDimensions.pillPadding,
                decoration: BoxDecoration(
                  color: AppColors.emeraldContainerDark.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(WearDimensions.pillRadius),
                  border: Border.all(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contact.taxCode,
                      style: WearTypography.codeDisplayCard(),
                      maxLines: 1,
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: WearDimensions.iconSmall,
                      color: AppColors.emeraldLight.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),

              if (metadataStr.isNotEmpty) ...[
                const SizedBox(height: 3.0),
                Text(
                  metadataStr,
                  style: WearTypography.cardSubtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
