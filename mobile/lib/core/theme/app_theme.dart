import 'package:material_ui/material_ui.dart';
import 'package:tax_code_flutter/core/theme/app_colors.dart';
import 'package:tax_code_flutter/core/theme/app_dimensions.dart';
import 'package:tax_code_flutter/core/theme/app_typography.dart';

export 'package:tax_code_flutter/core/theme/app_dimensions.dart';
export 'package:tax_code_flutter/core/theme/theme_context_extensions.dart';

/// Central theme configuration for the "Emerald Ledger" design system.
///
/// Implements Material 3 with full Dark (OLED-first) and Light mode specifications,
/// matching Google Stitch tokens:
/// - Pill-shaped buttons (stadium borders)
/// - 20-24px rounded cards with 1px low-contrast borders
/// - 16px rounded input fields with emerald focus outlines
/// - 28px rounded top bottom sheets with drag handles
/// - Inter for UI copy and JetBrains Mono for Codice Fiscale
abstract final class AppTheme {
  /// Dark Theme (OLED First).
  static ThemeData get darkTheme {
    final colorScheme = AppColors.darkColorScheme().toModern();
    final textTheme = AppTypography.createTextTheme(
      onSurface: colorScheme.onSurface,
      onSurfaceVariant: colorScheme.onSurfaceVariant,
    );
    return _buildTheme(colorScheme, textTheme);
  }

  /// Light Theme.
  static ThemeData get lightTheme {
    final colorScheme = AppColors.lightColorScheme().toModern();
    final textTheme = AppTypography.createTextTheme(
      onSurface: colorScheme.onSurface,
      onSurfaceVariant: colorScheme.onSurfaceVariant,
    );
    return _buildTheme(colorScheme, textTheme);
  }

  /// Single centralized theme builder that derives all component themes
  /// dynamically from the provided [colorScheme] and [textTheme].
  static ThemeData _buildTheme(ColorScheme colorScheme, TextTheme textTheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.none,
        surfaceTintColor: AppColors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: AppElevation.none,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderCard,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          elevation: AppElevation.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          elevation: AppElevation.none,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline, width: AppDimensions.borderThick),
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: isDark ? AppElevation.none : AppElevation.level1,
        focusElevation: isDark ? AppElevation.none : AppElevation.level1,
        hoverElevation: isDark ? AppElevation.none : AppElevation.levelHover,
        highlightElevation: isDark ? AppElevation.none : AppElevation.levelHover,
        shape: const StadiumBorder(),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        modalBackgroundColor: colorScheme.surfaceContainer,
        elevation: AppElevation.modal,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.borderSheet,
        ),
        dragHandleColor: colorScheme.outline,
        dragHandleSize: AppDimensions.dragHandleThemeSize,
        showDragHandle: true,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: AppSpacing.paddingField,
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppDimensions.borderSelected,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppDimensions.borderSelected,
          ),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.muted),
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // Segmented Button
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outline),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return colorScheme.surfaceContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurfaceVariant;
          }),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        elevation: AppElevation.dialog,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderDialog),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: AppDimensions.borderDefault,
        space: AppDimensions.borderDefault,
      ),
    );
  }
}
