import 'package:flutter/material.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/l10n/app_localizations_it.dart';

/// Extended floating action button for the dashboard, adhering to the
/// Emerald Ledger design system with pill/stadium styling.
///
/// Supports dynamic collapse/expansion (`isExtended`) during list scrolling
/// or based on viewport constraints.
class DashboardFab extends StatelessWidget {
  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the FAB displays both icon and label, or only the icon.
  final bool isExtended;

  /// Custom label override. Defaults to [AppLocalizations.newTaxCode].
  final String? label;

  /// Custom icon override. Defaults to [Icons.add_rounded].
  final Widget? icon;

  /// Custom tooltip override. Defaults to [AppLocalizations.newTaxCodeTooltip].
  final String? tooltip;

  /// Hero tag for page transitions. Defaults to 'dashboard_fab'.
  final Object? heroTag;

  const DashboardFab({
    super.key,
    required this.onPressed,
    this.isExtended = true,
    this.label,
    this.icon,
    this.tooltip,
    this.heroTag = 'dashboard_fab',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
    final fgColor = theme.floatingActionButtonTheme.foregroundColor ??
        colorScheme.onPrimary;

    final effectiveLabel = label ?? l10n.newTaxCode;
    final effectiveTooltip = tooltip ?? l10n.newTaxCodeTooltip;
    final effectiveIcon = icon ??
        Icon(
          Icons.add_rounded,
          size: 24,
          color: fgColor,
        );

    return FloatingActionButton.extended(
      key: const Key('dashboard_fab'),
      heroTag: heroTag,
      onPressed: onPressed,
      isExtended: isExtended,
      tooltip: effectiveTooltip,
      icon: effectiveIcon,
      label: Text(
        effectiveLabel,
        style: theme.textTheme.labelLarge?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
