import 'package:flutter_test/flutter_test.dart';
import 'package:shared/theme/app_colors.dart';
import 'package:shared/theme/app_dimensions.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_typography.dart';

void main() {
  group('WearTypography', () {
    test('specialized wear text styles use centralized tokens', () {
      final clockStyle = WearTypography.clockHeader();
      expect(clockStyle.fontSize, AppFontSizes.watchTitleMd);
      expect(clockStyle.letterSpacing, AppLetterSpacing.label);

      final cardTitleStyle = WearTypography.cardTitle();
      expect(cardTitleStyle.fontSize, AppFontSizes.watchTitleMd);
      expect(cardTitleStyle.letterSpacing, AppLetterSpacing.snug);
      expect(cardTitleStyle.height, AppLineHeights.heading);

      final cardSubtitleStyle = WearTypography.cardSubtitle();
      expect(cardSubtitleStyle.fontSize, AppFontSizes.micro);
      expect(cardSubtitleStyle.height, AppLineHeights.heading);

      final hintStyle = WearTypography.hint();
      expect(hintStyle.fontSize, AppFontSizes.watchMicro);
      expect(hintStyle.letterSpacing, AppLetterSpacing.subtle);

      final codeCardStyle = WearTypography.codeDisplayCard();
      expect(codeCardStyle.fontSize, AppFontSizes.caption);
      expect(codeCardStyle.letterSpacing, AppLetterSpacing.caption);
      expect(codeCardStyle.height, AppLineHeights.headerCompact);

      final codePresentationStyle = WearTypography.codeDisplayPresentation();
      expect(codePresentationStyle.fontSize, AppFontSizes.input);
      expect(codePresentationStyle.letterSpacing, AppLetterSpacing.wide);
      expect(codePresentationStyle.height, AppLineHeights.heading);

      final barcodeReadableStyle = WearTypography.barcodeReadableText();
      expect(barcodeReadableStyle.fontSize, AppFontSizes.micro);
      expect(barcodeReadableStyle.letterSpacing, AppLetterSpacing.wide);
    });

    test('createTextTheme builds complete TextTheme using watch tokens', () {
      final textTheme = WearTypography.createTextTheme(
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      );

      expect(textTheme.headlineMedium?.fontSize, AppFontSizes.bodyLg);
      expect(
        textTheme.headlineMedium?.letterSpacing,
        AppLetterSpacing.titleTight,
      );

      expect(textTheme.headlineSmall?.fontSize, AppFontSizes.bodyMd);

      expect(textTheme.titleMedium?.fontSize, AppFontSizes.titleSm);
      expect(textTheme.titleSmall?.fontSize, AppFontSizes.watchTitleSm);

      expect(textTheme.bodyMedium?.fontSize, AppFontSizes.bodySm);
      expect(textTheme.bodyMedium?.height, AppLineHeights.code);

      expect(textTheme.bodySmall?.fontSize, AppFontSizes.watchCaption);
      expect(textTheme.bodySmall?.height, AppLineHeights.displayCode);

      expect(textTheme.labelLarge?.fontSize, AppFontSizes.watchTitleMd);
      expect(textTheme.labelLarge?.letterSpacing, AppLetterSpacing.subtle);

      expect(textTheme.labelMedium?.fontSize, AppFontSizes.caption);
      expect(textTheme.labelMedium?.letterSpacing, AppLetterSpacing.subtle);

      expect(textTheme.labelSmall?.fontSize, AppFontSizes.watchMicro);
      expect(textTheme.labelSmall?.letterSpacing, AppLetterSpacing.tracked);
    });
  });
}
