import 'package:flutter/material.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/l10n/app_localizations_it.dart';

/// A modern search bar for the Dashboard following the Emerald Ledger design system.
///
/// Features:
/// - Pill-shaped search container (`BorderRadius.circular(9999)`).
/// - Dynamic focus and hover states with emerald accent outline.
/// - Leading search icon (`Icons.search_rounded`).
/// - Trailing clear button (`Icons.close_rounded`) visible when query is not empty.
/// - Optional card counter badge displaying localized count (e.g. "3 tessere salvate").
class DashboardSearchBar extends StatefulWidget {
  /// Controller for the search input text field.
  /// If omitted, an internal controller will be managed automatically.
  final TextEditingController? controller;

  /// Callback triggered whenever the search query text changes.
  final ValueChanged<String>? onChanged;

  /// Callback triggered when the clear button is pressed.
  final VoidCallback? onClear;

  /// Total number of saved cards to display in the badge.
  /// If null, the counter badge is omitted.
  final int? cardCount;

  /// Custom placeholder hint text. Defaults to localized [AppLocalizations.search].
  final String? hintText;

  /// Whether the search field should autofocus.
  final bool autofocus;

  const DashboardSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.cardCount,
    this.hintText,
    this.autofocus = false,
  });

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  late final TextEditingController _effectiveController;
  final FocusNode _focusNode = FocusNode();
  bool _isInternalController = false;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    } else {
      _effectiveController = widget.controller!;
    }

    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DashboardSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null && _isInternalController) {
        _effectiveController.removeListener(_handleTextChange);
        _effectiveController.dispose();
      } else {
        oldWidget.controller?.removeListener(_handleTextChange);
      }

      if (widget.controller == null) {
        _effectiveController = TextEditingController();
        _isInternalController = true;
      } else {
        _effectiveController = widget.controller!;
        _isInternalController = false;
      }

      _hasText = _effectiveController.text.isNotEmpty;
      _effectiveController.addListener(_handleTextChange);
    }
  }

  void _handleTextChange() {
    final hasTextNow = _effectiveController.text.isNotEmpty;
    if (_hasText != hasTextNow) {
      setState(() {
        _hasText = hasTextNow;
      });
    }
  }

  void _handleFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _effectiveController.removeListener(_handleTextChange);
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsIt();
    final isDark = theme.brightness == Brightness.dark;

    final containerColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    final borderColor = _isFocused
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pill-shaped search input container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 50,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: isDark ? 0.20 : 0.12),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              // Search leading icon
              Icon(
                Icons.search_rounded,
                size: 22,
                color: _isFocused
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 12),

              // Search text input
              Expanded(
                child: TextField(
                  key: const Key('dashboard_search_bar_text_field'),
                  controller: _effectiveController,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  textInputAction: TextInputAction.search,
                  onChanged: widget.onChanged,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: widget.hintText ?? l10n.search,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // Clear button (visible when query is non-empty)
              if (_hasText)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: IconButton(
                    key: const Key('dashboard_search_bar_clear_button'),
                    tooltip: l10n.searchClearTooltip,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _handleClear,
                  ),
                )
              else
                const SizedBox(width: 14),
            ],
          ),
        ),

        // Optional card count badge row
        if (widget.cardCount != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  key: const Key('dashboard_search_bar_count_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.12 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: colorScheme.primary.withValues(
                        alpha: isDark ? 0.28 : 0.20,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.style_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.savedCardsCount(widget.cardCount!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
