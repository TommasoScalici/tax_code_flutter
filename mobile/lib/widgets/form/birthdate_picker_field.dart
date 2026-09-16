import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// A modern date picker field with emerald calendar icon, 14px rounded corners,
/// and full dual-mode support (standalone or reactive via [formControlName]).
class BirthdatePickerField extends StatelessWidget {
  /// Reactive form control name when used inside a [ReactiveForm].
  final String? formControlName;

  /// Reactive form control instance when used directly.
  final FormControl<DateTime>? formControl;

  /// Custom label text above the field.
  final String? labelText;

  /// Whether the field displays an asterisk indicating required input.
  final bool isRequired;

  /// Validation messages mapping for reactive forms.
  final Map<String, ValidationMessageFunction>? validationMessages;

  /// Current selected date in standalone mode.
  final DateTime? value;

  /// Callback when date changes in standalone mode.
  final ValueChanged<DateTime?>? onChanged;

  /// Error message to display in standalone mode.
  final String? errorText;

  /// Minimum selectable date. Defaults to 1900-01-01.
  final DateTime? firstDate;

  /// Maximum selectable date. Defaults to today.
  final DateTime? lastDate;

  const BirthdatePickerField({
    super.key,
    this.formControlName,
    this.formControl,
    this.labelText,
    this.isRequired = true,
    this.validationMessages,
    this.value,
    this.onChanged,
    this.errorText,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    if (formControlName != null || formControl != null) {
      return ReactiveFormField<DateTime, DateTime>(
        formControlName: formControlName,
        formControl: formControl,
        validationMessages: validationMessages,
        builder: (field) {
          return _BirthdatePickerContent(
            value: field.value,
            onChanged: (newDate) {
              field.didChange(newDate);
              field.control.markAsTouched();
            },
            errorText: field.errorText,
            labelText: labelText,
            isRequired: isRequired,
            firstDate: firstDate,
            lastDate: lastDate,
          );
        },
      );
    }

    return _BirthdatePickerContent(
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      labelText: labelText,
      isRequired: isRequired,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }
}

class _BirthdatePickerContent extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final String? errorText;
  final String? labelText;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _BirthdatePickerContent({
    required this.value,
    this.onChanged,
    this.errorText,
    this.labelText,
    required this.isRequired,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final effectiveFirstDate = firstDate ?? DateTime(1900);
    final effectiveLastDate = lastDate ?? now;
    final initialDate = value ?? DateTime(1990);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(effectiveLastDate)
          ? effectiveLastDate
          : initialDate.isBefore(effectiveFirstDate)
              ? effectiveFirstDate
              : initialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      locale: Localizations.localeOf(context),
    );

    if (picked != null) {
      onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final hasError = errorText != null && errorText!.isNotEmpty;
    final resolvedLabel = labelText ?? l10n.birthDate;
    final placeholder = l10n.birthdateHint;

    final formattedDate = value != null
        ? DateFormat.yMd(Localizations.localeOf(context).toString()).format(value!)
        : '';

    final borderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.8);

    final bgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with required asterisk
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
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Input Field Container
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Material(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              key: const Key('birthdate_picker_inkwell'),
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        formattedDate.isNotEmpty ? formattedDate : placeholder,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: formattedDate.isNotEmpty
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontWeight: formattedDate.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (value != null)
                      IconButton(
                        key: const Key('birthdate_picker_clear_button'),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: colorScheme.onSurfaceVariant,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: l10n.close,
                        onPressed: () => onChanged?.call(null),
                      )
                    else
                      Icon(
                        Icons.calendar_month_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Error text
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
