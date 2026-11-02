import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_theme.dart';
import 'package:tax_code_flutter_wear_os/l10n/app_localizations.dart';
import 'package:tax_code_flutter_wear_os/services/demo_mode_service.dart';
import 'package:tax_code_flutter_wear_os/services/native_view_service.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/wear_preview_fakes.dart';

/// A specialized preview shell for Wear OS smartwatch displays.
///
/// Simulates:
/// - Round (Pixel Watch / Galaxy Watch) vs. Square watch faces.
/// - OLED-first dark design system with pure black display canvas.
/// - Watch hardware bezel with crown accent.
/// - Locale switching (IT / EN).
/// - Default fake providers ([NativeViewService], [AuthService], [DemoModeService]).
class WearPreviewShell extends StatefulWidget {
  const WearPreviewShell({
    this.child,
    this.builder,
    this.initialRound = true,
    this.initialLocale = const Locale('it'),
    this.displaySize = const Size(200, 200),
    this.providers = const [],
    this.toolbarActions,
    this.showToolbar = true,
    this.routes,
    this.onGenerateRoute,
    super.key,
  }) : assert(
         child != null || builder != null,
         'Either child or builder must be provided to WearPreviewShell',
       );

  /// Target widget to preview. Mutually exclusive with [builder].
  final Widget? child;

  /// Dynamic builder invoked with current watch shape (`isRound`).
  final Widget Function(BuildContext context, bool isRound)? builder;

  /// Whether the initial preview simulates a round smartwatch display.
  final bool initialRound;

  /// Initial locale for localization testing.
  final Locale initialLocale;

  /// Dimensions of the simulated smartwatch display (default 200x200 dp).
  final Size displaySize;

  /// Providers injected into the preview widget tree.
  final List<SingleChildWidget> providers;

  /// Additional action widgets rendered inside the top preview toolbar.
  final List<Widget> Function(BuildContext context, bool isRound)?
  toolbarActions;

  /// Whether to render the toolbar with shape and locale toggles.
  final bool showToolbar;

  /// Navigation routes table for preview navigation.
  final Map<String, WidgetBuilder>? routes;

  /// Route generator for preview navigation.
  final Route<dynamic>? Function(RouteSettings)? onGenerateRoute;

  @override
  State<WearPreviewShell> createState() => _WearPreviewShellState();
}

class _WearPreviewShellState extends State<WearPreviewShell> {
  late bool _isRound = widget.initialRound;
  late Locale _locale = widget.initialLocale;

  @override
  Widget build(BuildContext context) {
    final effectiveProviders = <SingleChildWidget>[
      Provider<NativeViewService>.value(value: const FakeNativeViewService()),
      ChangeNotifierProvider<AuthService>.value(value: FakeWearAuthService()),
      ChangeNotifierProvider<DemoModeService>.value(
        value: DefaultDemoModeService(),
      ),
      ...widget.providers,
    ];

    return MultiProvider(
      providers: effectiveProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: WearTheme.darkTheme,
        locale: _locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: widget.routes ?? const {},
        onGenerateRoute: widget.onGenerateRoute,
        home: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Column(
              children: [
                if (widget.showToolbar) _buildToolbar(context),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _buildWatchDevice(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Shape Switcher Pill
          ActionChip(
            avatar: Icon(
              _isRound ? Icons.circle_outlined : Icons.crop_square_rounded,
              size: 16,
              color: AppColors.emeraldLight,
            ),
            label: Text(
              _isRound ? 'Round (200dp)' : 'Square (200dp)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF0F172A),
            onPressed: () {
              setState(() {
                _isRound = !_isRound;
              });
            },
          ),

          // Locale Switcher Pill
          ActionChip(
            avatar: const Icon(
              Icons.language_rounded,
              size: 16,
              color: AppColors.emeraldLight,
            ),
            label: Text(
              _locale.languageCode.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF0F172A),
            onPressed: () {
              setState(() {
                _locale = _locale.languageCode == 'it'
                    ? const Locale('en')
                    : const Locale('it');
              });
            },
          ),

          // Custom extra actions
          if (widget.toolbarActions != null)
            ...widget.toolbarActions!(context, _isRound),
        ],
      ),
    );
  }

  Widget _buildWatchDevice(BuildContext context) {
    final screenW = widget.displaySize.width;
    final screenH = widget.displaySize.height;
    const bezelThickness = 14.0;
    final outerW = screenW + (bezelThickness * 2);
    final outerH = screenH + (bezelThickness * 2);

    final displayContent = Builder(
      builder: (ctx) {
        return widget.builder != null
            ? widget.builder!(ctx, _isRound)
            : widget.child!;
      },
    );

    return Container(
      width: outerW + 10, // Small allowance for watch crown
      height: outerH,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Simulated Physical Crown / Side Button
          Positioned(
            right: 0,
            top: (outerH / 2) - 14,
            child: Container(
              width: 8,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
            ),
          ),

          // Outer Watch Body / Bezel
          Container(
            width: outerW,
            height: outerH,
            decoration: BoxDecoration(
              shape: _isRound ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: _isRound ? null : BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF334155),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
              border: Border.all(color: const Color(0xFF475569), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              // Screen Viewport (Clipped to display shape)
              child: SizedBox(
                width: screenW,
                height: screenH,
                child: ClipPath(
                  clipper: _isRound ? const _CircleClipper() : null,
                  child: ClipRRect(
                    borderRadius: _isRound
                        ? BorderRadius.zero
                        : BorderRadius.circular(WearDimensions.cardRadius),
                    child: ColoredBox(
                      color: AppColors.darkBackground,
                      child: displayContent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper();

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
