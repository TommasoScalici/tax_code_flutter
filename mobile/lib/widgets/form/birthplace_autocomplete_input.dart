import 'package:material_ui/material_ui.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/utils/birthplace_search_filter.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_options_overlay.dart';

/// Pure presentation autocomplete input field for Italian municipalities and foreign countries.
///
/// Handles search filtering, suggestion overlay, text field formatting, clear button,
/// and focus synchronization independently of any form validation framework.
class BirthplaceAutocompleteInput extends StatefulWidget {
  /// External focus node to synchronize with scrolling or keyboard navigation.
  final FocusNode? focusNode;

  /// Full collection of birthplaces used for search filtering.
  final List<Birthplace> birthplaces;

  /// Current birthplace value.
  final Birthplace? value;

  /// Callback invoked when a birthplace is selected or cleared.
  final ValueChanged<Birthplace?>? onChanged;

  /// Custom label text overriding the default localized string.
  final String? labelText;

  /// Custom hint/placeholder text overriding the default localized string.
  final String? placeholder;

  /// Custom helper text displayed below the field overriding the default localized string.
  final String? helperText;

  /// Whether the field is mandatory (displays required asterisk when true).
  final bool isRequired;

  /// Error message to display when validation fails.
  final String? errorText;

  const BirthplaceAutocompleteInput({
    super.key,
    this.focusNode,
    this.birthplaces = const [],
    this.value,
    this.onChanged,
    this.labelText,
    this.placeholder,
    this.helperText,
    this.isRequired = true,
    this.errorText,
  });

  @override
  State<BirthplaceAutocompleteInput> createState() =>
      _BirthplaceAutocompleteInputState();
}

class _BirthplaceAutocompleteInputState
    extends State<BirthplaceAutocompleteInput> {
  late final TextEditingController _controller;
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant BirthplaceAutocompleteInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newText = widget.value?.toString() ?? '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedLabel = widget.labelText ?? l10n.birthPlace;
    final resolvedPlaceholder =
        widget.placeholder ?? l10n.birthplacePlaceholder;
    final resolvedHelperText = widget.helperText ?? l10n.birthplaceHelperText;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant.withValues(
            alpha: isDark ? AppOpacity.muted : AppOpacity.high,
          );

    final bgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with required asterisk
        Padding(
          padding: AppSpacing.labelPadding,
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
              if (widget.isRequired) ...[
                const SizedBox(width: AppSpacing.xs),
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

        // Autocomplete with field & options
        RawAutocomplete<Birthplace>(
          focusNode: _effectiveFocusNode,
          textEditingController: _controller,
          optionsBuilder: (textEditingValue) {
            return BirthplaceSearchFilter.search(
              widget.birthplaces,
              textEditingValue.text,
            );
          },
          displayStringForOption: (option) => option.toString(),
          onSelected: (option) {
            _effectiveFocusNode.unfocus();
            widget.onChanged?.call(option);
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            fieldFocusNode,
            onFieldSubmitted,
          ) {
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: textEditingController,
              builder: (context, textValue, _) {
                return TextField(
                  key: const Key('birthplace_autocomplete_textfield'),
                  controller: textEditingController,
                  focusNode: fieldFocusNode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSizes.input,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: resolvedPlaceholder,
                    errorText: widget.errorText,
                    filled: true,
                    fillColor: bgColor,
                    contentPadding: AppSpacing.paddingField,
                    border: OutlineInputBorder(
                      borderRadius: AppRadii.borderInput,
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadii.borderInput,
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadii.borderInput,
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: AppDimensions.borderThick,
                      ),
                    ),
                    suffixIcon: textValue.text.isNotEmpty
                        ? IconButton(
                            key: const Key('birthplace_clear_button'),
                            icon: const Icon(
                              Icons.clear,
                              size: AppDimensions.iconAction,
                            ),
                            color: colorScheme.onSurfaceVariant,
                            onPressed: () {
                              textEditingController.clear();
                              widget.onChanged?.call(null);
                              fieldFocusNode.unfocus();
                            },
                          )
                        : Icon(
                            Icons.location_on_rounded,
                            color: colorScheme.primary,
                            size: AppDimensions.iconMd,
                          ),
                  ),
                );
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return BirthplaceOptionsOverlay(
              options: options,
              onSelected: onSelected,
            );
          },
        ),

        // Helper text below field
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            top: AppSpacing.badgeVertical,
          ),
          child: Text(
            resolvedHelperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(
                alpha: AppOpacity.medium,
              ),
              fontSize: AppFontSizes.caption,
              height: AppLineHeights.code,
            ),
          ),
        ),
      ],
    );
  }
}
