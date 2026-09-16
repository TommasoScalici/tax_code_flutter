import 'package:material_ui/material_ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';
import 'package:shared/models/birthplace.dart';
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

        // Autocomplete with field & options
        ReactiveRawAutocomplete<Birthplace, Birthplace>(
          formControlName: formControlName,
          focusNode: focusNode,
          validationMessages: {
            ValidationMessage.required: (error) => l10n.required,
          },
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.length < 2) {
              return const Iterable<Birthplace>.empty();
            }
            final query = textEditingValue.text.toLowerCase();
            return birthplaces
                .where((b) => b.name.toLowerCase().contains(query))
                .take(20)
                .toList();
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
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: placeholder,
                        errorText: fieldError,
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
                        suffixIcon: textValue.text.isNotEmpty
                            ? IconButton(
                                key: const Key('birthplace_clear_button'),
                                icon: const Icon(Icons.clear, size: 18),
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
                                size: 20,
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
          padding: const EdgeInsets.only(left: 4.0, top: 5.0),
          child: Text(
            helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 11,
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
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.8);

    final bgColor = isDark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
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

        // Standalone RawAutocomplete
        RawAutocomplete<Birthplace>(
          focusNode: _effectiveFocusNode,
          textEditingController: _controller,
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.length < 2) {
              return const Iterable<Birthplace>.empty();
            }
            final query = textEditingValue.text.toLowerCase();
            return widget.birthplaces
                .where((b) => b.name.toLowerCase().contains(query))
                .take(20)
                .toList();
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
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    errorText: widget.errorText,
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
                    suffixIcon: textValue.text.isNotEmpty
                        ? IconButton(
                            key: const Key('birthplace_clear_button'),
                            icon: const Icon(Icons.clear, size: 18),
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
                            size: 20,
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
          padding: const EdgeInsets.only(left: 4.0, top: 5.0),
          child: Text(
            widget.helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 11,
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
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 250, maxWidth: 360),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.6 : 0.8,
              ),
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final birthplace = options.elementAt(index);
              final isForeign = birthplace.state == 'EE';

              return InkWell(
                onTap: () => onSelected(birthplace),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isForeign
                            ? Icons.public_rounded
                            : Icons.location_city_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
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
                      const SizedBox(width: 8),
                      // Province Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.6 : 0.4,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          birthplace.state,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
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
