import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared/models/birthplace.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';

/// Anagraphic details row in `ContactCard`, displaying birthplace and localized birthdate.
class ContactCardAnagraphics extends StatelessWidget {
  /// The birthplace of the contact.
  final Birthplace birthPlace;

  /// The birthdate of the contact.
  final DateTime birthDate;

  /// Creates a [ContactCardAnagraphics].
  const ContactCardAnagraphics({
    required this.birthPlace,
    required this.birthDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final formattedBirthDate = DateFormat.yMd(
      Localizations.localeOf(context).toString(),
    ).format(birthDate);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.place_outlined,
              size: AppDimensions.iconXs,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              birthPlace.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          '•',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.outlineVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: AppDimensions.iconXs,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              formattedBirthDate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
