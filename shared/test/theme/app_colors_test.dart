import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('darkColorScheme returns valid Material 3 ColorScheme with semantic dark tokens', () {
      final scheme = AppColors.darkColorScheme();

      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, AppColors.emeraldPrimary);
      expect(scheme.onPrimary, AppColors.darkOnPrimary);
      expect(scheme.primaryContainer, AppColors.emeraldContainerDark);
      expect(scheme.onPrimaryContainer, AppColors.emeraldLight);
      expect(scheme.secondary, AppColors.darkSecondary);
      expect(scheme.onSecondary, AppColors.darkOnSecondary);
      expect(scheme.secondaryContainer, AppColors.darkSecondaryContainer);
      expect(scheme.onSecondaryContainer, AppColors.darkOnSecondaryContainer);
      expect(scheme.tertiary, AppColors.darkTertiary);
      expect(scheme.onTertiary, AppColors.darkOnTertiary);
      expect(scheme.tertiaryContainer, AppColors.darkTertiaryContainer);
      expect(scheme.onTertiaryContainer, AppColors.darkOnTertiaryContainer);
      expect(scheme.error, AppColors.darkError);
      expect(scheme.onError, AppColors.darkOnError);
      expect(scheme.errorContainer, AppColors.darkErrorContainer);
      expect(scheme.onErrorContainer, AppColors.darkOnErrorContainer);
      expect(scheme.surface, AppColors.darkSurface);
      expect(scheme.onSurface, AppColors.darkOnSurface);
      expect(scheme.surfaceBright, AppColors.darkSurfaceBright);
      expect(scheme.surfaceContainerLowest, AppColors.darkSurfaceContainerLowest);
      expect(scheme.surfaceContainerLow, AppColors.darkSurfaceContainerLow);
      expect(scheme.surfaceContainer, AppColors.darkSurfaceContainer);
      expect(scheme.surfaceContainerHigh, AppColors.darkSurfaceContainerHigh);
      expect(scheme.surfaceContainerHighest, AppColors.darkSurfaceContainerHighest);
      expect(scheme.onSurfaceVariant, AppColors.darkOnSurfaceVariant);
      expect(scheme.outline, AppColors.darkOutline);
      expect(scheme.outlineVariant, AppColors.darkOutlineVariant);
      expect(scheme.shadow, AppColors.opticalBlack);
      expect(scheme.scrim, AppColors.opticalBlack);
      expect(scheme.inverseSurface, AppColors.darkInverseSurface);
      expect(scheme.onInverseSurface, AppColors.darkOnInverseSurface);
      expect(scheme.inversePrimary, AppColors.darkInversePrimary);
    });

    test('lightColorScheme returns valid Material 3 ColorScheme with semantic light tokens', () {
      final scheme = AppColors.lightColorScheme();

      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, AppColors.lightPrimary);
      expect(scheme.onPrimary, AppColors.lightOnPrimary);
      expect(scheme.primaryContainer, AppColors.lightPrimaryContainer);
      expect(scheme.onPrimaryContainer, AppColors.lightOnPrimaryContainer);
      expect(scheme.secondary, AppColors.lightSecondary);
      expect(scheme.onSecondary, AppColors.lightOnSecondary);
      expect(scheme.secondaryContainer, AppColors.lightSecondaryContainer);
      expect(scheme.onSecondaryContainer, AppColors.lightOnSecondaryContainer);
      expect(scheme.tertiary, AppColors.lightTertiary);
      expect(scheme.onTertiary, AppColors.lightOnTertiary);
      expect(scheme.tertiaryContainer, AppColors.lightTertiaryContainer);
      expect(scheme.onTertiaryContainer, AppColors.lightOnTertiaryContainer);
      expect(scheme.error, AppColors.lightError);
      expect(scheme.onError, AppColors.lightOnError);
      expect(scheme.errorContainer, AppColors.lightErrorContainer);
      expect(scheme.onErrorContainer, AppColors.lightOnErrorContainer);
      expect(scheme.surface, AppColors.lightSurface);
      expect(scheme.onSurface, AppColors.lightOnSurface);
      expect(scheme.surfaceDim, AppColors.lightSurfaceDim);
      expect(scheme.surfaceBright, AppColors.lightSurfaceBright);
      expect(scheme.surfaceContainerLowest, AppColors.lightSurfaceContainerLowest);
      expect(scheme.surfaceContainerLow, AppColors.lightSurfaceContainerLow);
      expect(scheme.surfaceContainer, AppColors.lightSurfaceContainer);
      expect(scheme.surfaceContainerHigh, AppColors.lightSurfaceContainerHigh);
      expect(scheme.surfaceContainerHighest, AppColors.lightSurfaceContainerHighest);
      expect(scheme.onSurfaceVariant, AppColors.lightOnSurfaceVariant);
      expect(scheme.outline, AppColors.lightOutline);
      expect(scheme.outlineVariant, AppColors.lightOutlineVariant);
      expect(scheme.shadow, AppColors.opticalBlack);
      expect(scheme.scrim, AppColors.opticalBlack);
      expect(scheme.inverseSurface, AppColors.lightInverseSurface);
      expect(scheme.onInverseSurface, AppColors.lightOnInverseSurface);
      expect(scheme.inversePrimary, AppColors.emeraldLight);
    });

    test('shadow helpers produce distinct dark and light shadows', () {
      final cardDark = AppColors.shadowCard(true);
      final cardLight = AppColors.shadowCard(false);
      expect(cardDark.blurRadius, 16);
      expect(cardLight.blurRadius, 16);
      expect(cardDark.color, isNot(equals(cardLight.color)));

      final sheetDark = AppColors.shadowSheet(true);
      final sheetLight = AppColors.shadowSheet(false);
      expect(sheetDark.blurRadius, 32);
      expect(sheetLight.blurRadius, 32);

      final elevatedDark = AppColors.shadowElevated(true);
      final elevatedLight = AppColors.shadowElevated(false);
      expect(elevatedDark.blurRadius, 20);
      expect(elevatedLight.blurRadius, 20);

      final previewDark = AppColors.shadowPreviewCard(true);
      final previewLight = AppColors.shadowPreviewCard(false);
      expect(previewDark.blurRadius, 24);
      expect(previewLight.blurRadius, 24);
    });
  });
}
