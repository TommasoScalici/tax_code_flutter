import 'package:material_ui/material_ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/utils/birthplace_search_filter.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';

/// A modern autocomplete field for Italian municipalities and foreign countries,
/// featuring location pin icon, clear button, cadastral code badge, and helper text.
class BirthplaceAutocompleteField extends StatelessWidget {
  /// Reactive form control name when used inside [ReactiveForm].
  final String? formControlName;

  /// Direct reactive control instance.
  final AbstractControl<dynamic>? formControl;

  /// External focus node to synchronize with page scrolling.
  final FocusNode? focusNode;

  /// Optional custom label text.
  final String? labelText;

  /// Full collection of birthplaces for filtering.
  final List<Birthplace> birthplaces;

  /// Callback when a birthplace is selected.
  final ValueChanged<Birthplace?>? onChanged;

  /// Current value when used in standalone mode without ReactiveForms.
  final Birthplace? value;

  /// Whether the field is required (displays asterisk when true).
  final bool isRequired;

  /// Custom error message to display in standalone mode.
  final String? errorText;

  const BirthplaceAutocompleteField({
    super.key,
    this.formControlName,
    this.formControl,
    this.focusNode,
    this.labelText,
    this.birthplaces = const [],
    this.onChanged,
    this.value,
    this.isRequired = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedLabel = labelText ?? l10n.birthPlace;
    final placeholder = l10n.birthplacePlaceholder;
    final helperText = l10n.birthplaceHelperText;

    // Standalone mode if formControlName is omitted
    if (formControlName == null && formControl == null) {
      return _StandaloneBirthplaceAutocomplete(
        focusNode: focusNode,
        birthplaces: birthplaces,
        value: value,
        onChanged: onChanged,
        labelText: resolvedLabel,
        placeholder: placeholder,
        helperText: helperText,
        isRequired: isRequired,
        errorText: errorText,
      );
    }

    // Reactive form mode
    final formGroup = ReactiveForm.of(context) as FormGroup?;
    final control = formGroup?.control(formControlName!) as FormControl<dynamic>?;

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
              if (isRequired) ...[
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
        ReactiveRawAutocomplete<Birthplace, Birthplace>(
          formControlName: formControlName,
          focusNode: focusNode,
          validationMessages: {
            ValidationMessage.required: (error) => l10n.required,
          },
          optionsBuilder: (textEditingValue) {
            return BirthplaceSearchFilter.search(
              birthplaces,
              textEditingValue.text,
            );
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            fieldFocusNode,
            onFieldSubmitted,
          ) {
            return ReactiveValueListenableBuilder<dynamic>(
              formControl: control,
              builder: (context, currentControl, child) {
                final hasError =
                    currentControl.invalid && currentControl.touched;
                final fieldError = hasError ? l10n.required : null;

                final borderColor = hasError
                    ? colorScheme.error
                    : colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.6 : 0.8,
                      );

                final bgColor = isDark
                    ? colorScheme.surfaceContainer
                    : colorScheme.surfaceContainerLow;

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
                        hintText: placeholder,
                        errorText: fieldError,
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
                                icon: const Icon(Icons.clear, size: AppDimensions.iconAction),
                                color: colorScheme.onSurfaceVariant,
                                onPressed: () {
                                  textEditingController.clear();
                                  if (control != null) {
                                    control.value = null;
                                    control.markAsTouched();
                                  }
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
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return _BirthplaceOptionsOverlay(
              options: options,
              onSelected: onSelected,
            );
          },
        ),

        // Helper text below field
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, top: 5.0),
          child: Text(
            helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.medium),
              fontSize: AppFontSizes.caption,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _StandaloneBirthplaceAutocomplete extends StatefulWidget {
  final FocusNode? focusNode;
  final List<Birthplace> birthplaces;
  final Birthplace? value;
  final ValueChanged<Birthplace?>? onChanged;
  final String labelText;
  final String placeholder;
  final String helperText;
  final bool isRequired;
  final String? errorText;

  const _StandaloneBirthplaceAutocomplete({
    this.focusNode,
    required this.birthplaces,
    required this.value,
    required this.onChanged,
    required this.labelText,
    required this.placeholder,
    required this.helperText,
    required this.isRequired,
    this.errorText,
  });

  @override
  State<_StandaloneBirthplaceAutocomplete> createState() =>
      _StandaloneBirthplaceAutocompleteState();
}

class _StandaloneBirthplaceAutocompleteState
    extends State<_StandaloneBirthplaceAutocomplete> {
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
  void didUpdateWidget(covariant _StandaloneBirthplaceAutocomplete oldWidget) {
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
    final isDark = theme.brightness == Brightness.dark;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant.withValues(alpha: isDark ? AppOpacity.muted : AppOpacity.high);

    final bgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: AppSpacing.labelPadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.labelText,
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

        // Standalone RawAutocomplete
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
                    hintText: widget.placeholder,
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
                            icon: const Icon(Icons.clear, size: AppDimensions.iconAction),
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
            return _BirthplaceOptionsOverlay(
              options: options,
              onSelected: onSelected,
            );
          },
        ),

        // Helper text
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, top: 5.0),
          child: Text(
            widget.helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.medium),
              fontSize: AppFontSizes.caption,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _BirthplaceOptionsOverlay extends StatelessWidget {
  final Iterable<Birthplace> options;
  final AutocompleteOnSelected<Birthplace> onSelected;

  const _BirthplaceOptionsOverlay({
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 6.0,
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLowest,
        borderRadius: AppRadii.borderMd,
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 250,
            maxWidth: AppDimensions.maxDropdownWidth,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.borderMd,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: isDark ? AppOpacity.muted : AppOpacity.high,
              ),
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.badgeGap),
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: AppDimensions.borderHairline,
              color: colorScheme.outlineVariant.withValues(alpha: AppOpacity.translucent),
            ),
            itemBuilder: (context, index) {
              final birthplace = options.elementAt(index);
              final isForeign = birthplace.state == 'EE';

              return InkWell(
                onTap: () => onSelected(birthplace),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.compact,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isForeign
                            ? Icons.public_rounded
                            : Icons.location_city_rounded,
                        size: AppDimensions.iconAction,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          birthplace.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Province Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.badgeGap,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.6 : 0.4,
                          ),
                          borderRadius: AppRadii.borderBadge,
                        ),
                        child: Text(
                          birthplace.state,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                            fontSize: AppFontSizes.caption,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
