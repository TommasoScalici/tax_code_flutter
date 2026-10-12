import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tax_code_flutter/core/theme/app_theme.dart';
import 'package:tax_code_flutter/l10n/app_localizations_setup.dart';

/// A unified wrapper for widget and screen previews.
///
/// Encapsulates boilerplate for:
/// - [MaterialApp] configuration with [AppTheme.lightTheme] and [AppTheme.darkTheme].
/// - Dynamic dark/light mode toggle toolbar.
/// - Dynamic locale switching (IT / EN).
/// - Centralized [Provider] injection.
/// - Configurable viewport constraints, padding, and scrolling.
class PreviewShell extends StatefulWidget {
  const PreviewShell({
    this.child,
    this.builder,
    this.maxWidth = 440.0,
    this.maxHeight,
    this.expandChild = false,
    this.padding = AppSpacing.paddingCard,
    this.scrollable = true,
    this.initialDarkMode = true,
    this.initialLocale = const Locale('it'),
    this.providers = const [],
    this.toolbarActions,
    this.showToolbar = true,
    super.key,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided to PreviewShell',
       );

  /// The target widget to preview. Mutually exclusive with [builder].
  final Widget? child;

  /// Dynamic builder invoked when the preview state (theme/locale) changes.
  final Widget Function(BuildContext context, bool isDarkMode)? builder;

  /// Maximum viewport width. When null, expands to full width (ideal for screens).
  final double? maxWidth;

  /// Maximum viewport height. When null, defaults to unbounded height.
  final double? maxHeight;

  /// Whether the [child] or [builder] widget should be wrapped in an [Expanded] widget.
  /// Useful for full screens containing scaffolds or scroll views.
  final bool expandChild;

  /// Padding applied around the preview content.
  final EdgeInsets padding;

  /// Whether the viewport should be wrapped in a [SingleChildScrollView].
  final bool scrollable;

  /// Initial theme mode state.
  final bool initialDarkMode;

  /// Initial locale for localization.
  final Locale initialLocale;

  /// Optional list of providers to inject into the widget tree.
  final List<SingleChildWidget> providers;

  /// Additional action widgets rendered inside the preview toolbar.
  final List<Widget> Function(BuildContext context, bool isDarkMode)?
  toolbarActions;

  /// Whether to display the top preview toolbar (theme & locale toggles).
  final bool showToolbar;

  /// Displays floating feedback snackbar for callback demonstration.
  static void showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  State<PreviewShell> createState() => _PreviewShellState();
}

class _PreviewShellState extends State<PreviewShell> {
  late bool _isDarkMode = widget.initialDarkMode;
  late Locale _locale = widget.initialLocale;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final l10n = context.l10n;

          final extraActions =
              widget.toolbarActions?.call(context, _isDarkMode) ??
              const <Widget>[];

          final toolbar = widget.showToolbar
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ActionChip(
                        avatar: Icon(
                          _isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          size: AppDimensions.iconXs,
                        ),
                        label: Text(
                          _isDarkMode ? l10n.themeDark : l10n.themeLight,
                        ),
                        onPressed: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.language,
                          size: AppDimensions.iconXs,
                        ),
                        label: Text(_locale.languageCode.toUpperCase()),
                        onPressed: () {
                          setState(() {
                            _locale = _locale.languageCode == 'it'
                                ? const Locale('en')
                                : const Locale('it');
                          });
                        },
                      ),
                      ...extraActions,
                    ],
                  ),
                )
              : null;

          final targetWidget =
              widget.builder?.call(context, _isDarkMode) ?? widget.child!;

          Widget bodyContent;
          if (widget.expandChild) {
            if (widget.maxWidth != null || widget.maxHeight != null) {
              bodyContent = Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.maxWidth ?? double.infinity,
                    maxHeight: widget.maxHeight ?? double.infinity,
                  ),
                  child: Padding(
                    padding: widget.padding,
                    child: targetWidget,
                  ),
                ),
              );
            } else if (widget.padding != EdgeInsets.zero) {
              bodyContent = Padding(
                padding: widget.padding,
                child: targetWidget,
              );
            } else {
              bodyContent = targetWidget;
            }
          } else if (widget.scrollable) {
            bodyContent = SingleChildScrollView(
              padding: widget.padding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.maxWidth ?? double.infinity,
                    maxHeight: widget.maxHeight ?? double.infinity,
                  ),
                  child: targetWidget,
                ),
              ),
            );
          } else {
            Widget unscrollableContent = targetWidget;
            if (widget.maxWidth != null || widget.maxHeight != null) {
              unscrollableContent = Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.maxWidth ?? double.infinity,
                    maxHeight: widget.maxHeight ?? double.infinity,
                  ),
                  child: Padding(
                    padding: widget.padding,
                    child: unscrollableContent,
                  ),
                ),
              );
            } else if (widget.padding != EdgeInsets.zero) {
              unscrollableContent = Padding(
                padding: widget.padding,
                child: unscrollableContent,
              );
            }
            bodyContent = unscrollableContent;
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?toolbar,
                  Expanded(child: bodyContent),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (widget.providers.isNotEmpty) {
      return MultiProvider(
        providers: widget.providers,
        child: app,
      );
    }

    return app;
  }
}
