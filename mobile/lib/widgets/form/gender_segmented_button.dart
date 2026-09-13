import 'package:material_ui/material_ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

/// A modern, accessible Material 3 segmented button for selecting gender
/// ('M' for Male, 'F' for Female).
///
/// Designed to replace the legacy dropdown with an emerald active fill,
/// checkmark indicator, and full reactive-forms integration.
class GenderSegmentedButton extends StatelessWidget {
  /// Reactive form control name when used inside a [ReactiveForm].
  final String? formControlName;

  /// Reactive form control instance when used directly.
  final FormControl<String>? formControl;

  /// Custom label text displayed above the control.
  final String? labelText;

  /// Whether the field is marked with an asterisk indicating required input.
  final bool isRequired;

  /// Validation message mapping for [ReactiveFormField].
  final Map<String, ValidationMessageFunction>? validationMessages;

  /// Current value when used in standalone mode without [ReactiveForm].
  final String? value;

  /// Callback triggered when the value changes in standalone mode.
  final ValueChanged<String?>? onChanged;

  /// Error text displayed below the widget in standalone mode.
  final String? errorText;

  const GenderSegmentedButton({
    super.key,
    this.formControlName,
    this.formControl,
    this.labelText,
    this.isRequired = true,
    this.validationMessages,
    this.value,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (formControlName != null || formControl != null) {
      return ReactiveFormField<String, String>(
        formControlName: formControlName,
        formControl: formControl,
        validationMessages: validationMessages,
        builder: (field) {
          return _GenderSegmentedLayout(
            value: field.value,
            onChanged: (newVal) {
              field.didChange(newVal);
              field.control.markAsTouched();
            },
            errorText: field.errorText,
            labelText: labelText,
            isRequired: isRequired,
          );
        },
      );
    }

    return _GenderSegmentedLayout(
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      labelText: labelText,
      isRequired: isRequired,
    );
  }
}

class _GenderSegmentedLayout extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? errorText;
  final String? labelText;
  final bool isRequired;

  const _GenderSegmentedLayout({
    required this.value,
    this.onChanged,
    this.errorText,
    this.labelText,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasError = errorText != null && errorText!.isNotEmpty;

    final resolvedLabel = labelText ?? l10n?.gender ?? 'Sesso';
    final maleLabel = l10n?.genderMale ?? 'Maschile (M)';
    final femaleLabel = l10n?.genderFemale ?? 'Femminile (F)';

    final containerBorderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with optional required asterisk
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resolvedLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Segmented Box
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainer
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: containerBorderColor, width: 1.0),
          ),
          child: Row(
            children: [
              // Male Segment
              Expanded(
                child: _GenderSegmentOption(
                  key: const Key('gender_segment_m'),
                  label: maleLabel,
                  isSelected: value == 'M',
                  onTap: () {
                    final newValue = value == 'M' ? null : 'M';
                    onChanged?.call(newValue);
                  },
                ),
              ),
              const SizedBox(width: 4),
              // Female Segment
              Expanded(
                child: _GenderSegmentOption(
                  key: const Key('gender_segment_f'),
                  label: femaleLabel,
                  isSelected: value == 'F',
                  onTap: () {
                    final newValue = value == 'F' ? null : 'F';
                    onChanged?.call(newValue);
                  },
                ),
              ),
            ],
          ),
        ),

        // Error message if present
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 6.0),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _GenderSegmentOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderSegmentOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg = colorScheme.primary.withValues(
      alpha: isDark ? 0.16 : 0.12,
    );

    final selectedBorder = Border.all(
      color: colorScheme.primary.withValues(alpha: isDark ? 0.85 : 0.75),
      width: 1.2,
    );

    return Material(
      color: isSelected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? selectedBorder : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
