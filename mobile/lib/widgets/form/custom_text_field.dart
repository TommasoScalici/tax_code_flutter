import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// A modern text input field designed for the Stitch design system.
///
/// Features an external label with an optional required asterisk, 14px rounded
/// container, theme-aware surface styling, clear visual states (idle, focus, error),
/// and customizable suffix icon and capitalization.
class CustomTextField extends StatelessWidget {
  /// The reactive form control name.
  final String formControlName;

  /// The label displayed above the field.
  final String labelText;

  /// Optional placeholder text shown when the field is empty.
  final String? placeholder;

  /// Whether to display a primary-colored required asterisk next to the label.
  final bool isRequired;

  /// Custom suffix icon widget. Defaults to a subtle person icon.
  final Widget? suffixIcon;

  /// Capitalization behavior for input text. Defaults to [TextCapitalization.words].
  final TextCapitalization textCapitalization;

  /// The keyboard action button to display. Defaults to [TextInputAction.next].
  final TextInputAction textInputAction;

  /// Custom reactive validation error messages.
  final Map<String, ValidationMessageFunction>? validationMessages;

  const CustomTextField({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.placeholder,
    this.isRequired = true,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.next,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.6 : 0.8,
    );
    final bgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top label with optional required asterisk
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                labelText,
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

        // Reactive text field
        Material(
          type: MaterialType.transparency,
          child: ReactiveTextField<String>(
            formControlName: formControlName,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            validationMessages: validationMessages,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: bgColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.6,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1.6,
                ),
              ),
              suffixIcon: suffixIcon ??
                  Icon(
                    Icons.person_outline_rounded,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    size: 20,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
