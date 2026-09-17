import 'package:flutter/material.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';

export 'package:tax_code_flutter_wear_os/core/theme/theme_context_extensions.dart';
export 'package:tax_code_flutter_wear_os/core/theme/wear_colors.dart';
export 'package:tax_code_flutter_wear_os/core/theme/wear_dimensions.dart';
export 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';

/// Central theme configuration for the Wear OS "Emerald Ledger" design system.
///
/// Implements Material 3 with full Dark (OLED-first) specifications,
/// calibrated for compact watch displays:
/// - Pure black OLED backgrounds (`#121212`) for maximum energy efficiency
/// - Dark charcoal cards (`#1E1E1E`) with 18px rounded corners and 1px low-contrast borders
/// - Pill-shaped buttons (stadium borders)
/// - Monospace styling for Codice Fiscale
abstract final class WearTheme {
  /// Dark Theme (OLED First) for Wear OS.
  static ThemeData get darkTheme {
    final colorScheme = AppColors.darkColorScheme();
    final textTheme = WearTypography.createTextTheme(
      onSurface: colorScheme.onSurface,
      onSurfaceVariant: colorScheme.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,

      // Card
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WearDimensions.cardRadius),
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
          minimumSize: const Size.fromHeight(WearDimensions.buttonHeight),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHigh,
          foregroundColor: colorScheme.onSurface,
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(WearDimensions.buttonHeight),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(WearDimensions.buttonHeight),
          textStyle: textTheme.labelMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelMedium,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icons
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: WearDimensions.iconMedium,
      ),
    );
  }
}
