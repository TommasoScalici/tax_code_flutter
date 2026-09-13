import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/widgets/previews/barcode_bottom_sheet_preview.dart';
import 'package:tax_code_flutter/widgets/previews/birthdate_picker_field_preview.dart';
import 'package:tax_code_flutter/widgets/previews/birthplace_autocomplete_field_preview.dart';
import 'package:tax_code_flutter/widgets/previews/contact_card_preview.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_empty_state_preview.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_fab_preview.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_header_preview.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_screen_preview.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_search_bar_preview.dart';
import 'package:tax_code_flutter/widgets/previews/form_screen_preview.dart';
import 'package:tax_code_flutter/widgets/previews/form_section_divider_preview.dart';
import 'package:tax_code_flutter/widgets/previews/form_sticky_bottom_bar_preview.dart';
import 'package:tax_code_flutter/widgets/previews/gender_segmented_button_preview.dart';
import 'package:tax_code_flutter/widgets/previews/ocr_ai_hero_banner_preview.dart';
import 'package:tax_code_flutter/widgets/previews/tax_code_live_preview_card_preview.dart';
import 'package:tax_code_flutter/widgets/previews/theme_showcase_preview.dart';
import 'package:tax_code_flutter/widgets/previews/welcome_screen_preview.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(setupTests);

  testWidgets('pumps WelcomeScreenPreview without error', (tester) async {
    await tester.pumpWidget(const WelcomeScreenPreview());
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreenPreview), findsOneWidget);
  });

  testWidgets('pumps ThemeShowcasePreview without error', (tester) async {
    await tester.pumpWidget(const ThemeShowcasePreview());
    await tester.pumpAndSettle();
    expect(find.byType(ThemeShowcasePreview), findsOneWidget);
  });

  testWidgets('pumps DashboardHeaderPreview without error', (tester) async {
    await tester.pumpWidget(const DashboardHeaderPreview());
    await tester.pumpAndSettle();
    expect(find.byType(DashboardHeaderPreview), findsOneWidget);
  });

  testWidgets('pumps DashboardSearchBarPreview without error', (tester) async {
    await tester.pumpWidget(const DashboardSearchBarPreview());
    await tester.pumpAndSettle();
    expect(find.byType(DashboardSearchBarPreview), findsOneWidget);
  });

  testWidgets('pumps ContactCardPreview without error', (tester) async {
    await tester.pumpWidget(const ContactCardPreview());
    await tester.pumpAndSettle();
    expect(find.byType(ContactCardPreview), findsOneWidget);
  });

  testWidgets('pumps DashboardEmptyStatePreview without error', (tester) async {
    await tester.pumpWidget(const DashboardEmptyStatePreview());
    await tester.pumpAndSettle();
    expect(find.byType(DashboardEmptyStatePreview), findsOneWidget);
  });

  testWidgets('pumps DashboardFabPreview without error', (tester) async {
    await tester.pumpWidget(const DashboardFabPreview());
    await tester.pumpAndSettle();
    expect(find.byType(DashboardFabPreview), findsOneWidget);
  });

  testWidgets('pumps DashboardScreenPreview without error', (tester) async {
    await tester.pumpWidget(const DashboardScreenPreview());
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreenPreview), findsOneWidget);
  });

  testWidgets('pumps OcrAiHeroBannerPreview without error', (tester) async {
    await tester.pumpWidget(const OcrAiHeroBannerPreview());
    await tester.pumpAndSettle();
    expect(find.byType(OcrAiHeroBannerPreview), findsOneWidget);
  });

  testWidgets('pumps FormSectionDividerPreview without error', (tester) async {
    await tester.pumpWidget(const FormSectionDividerPreview());
    await tester.pumpAndSettle();
    expect(find.byType(FormSectionDividerPreview), findsOneWidget);
  });

  testWidgets('pumps GenderSegmentedButtonPreview without error', (
    tester,
  ) async {
    await tester.pumpWidget(const GenderSegmentedButtonPreview());
    await tester.pumpAndSettle();
    expect(find.byType(GenderSegmentedButtonPreview), findsOneWidget);
  });

  testWidgets('pumps BirthdatePickerFieldPreview without error', (
    tester,
  ) async {
    await tester.pumpWidget(const BirthdatePickerFieldPreview());
    await tester.pumpAndSettle();
    expect(find.byType(BirthdatePickerFieldPreview), findsOneWidget);
  });

  testWidgets('pumps BirthplaceAutocompleteFieldPreview without error', (
    tester,
  ) async {
    await tester.pumpWidget(const BirthplaceAutocompleteFieldPreview());
    await tester.pumpAndSettle();
    expect(find.byType(BirthplaceAutocompleteFieldPreview), findsOneWidget);
  });

  testWidgets('pumps TaxCodeLivePreviewCardPreview without error', (
    tester,
  ) async {
    await tester.pumpWidget(const TaxCodeLivePreviewCardPreview());
    await tester.pumpAndSettle();
    expect(find.byType(TaxCodeLivePreviewCardPreview), findsOneWidget);
  });

  testWidgets('pumps FormStickyBottomBarPreview without error', (
    tester,
  ) async {
    await tester.pumpWidget(const FormStickyBottomBarPreview());
    await tester.pumpAndSettle();
    expect(find.byType(FormStickyBottomBarPreview), findsOneWidget);
  });

  testWidgets('pumps FormScreenPreview without error', (tester) async {
    await tester.pumpWidget(const FormScreenPreview());
    await tester.pumpAndSettle();
    expect(find.byType(FormScreenPreview), findsOneWidget);
  });

  testWidgets('pumps BarcodeBottomSheetPreview without error', (tester) async {
    await tester.pumpWidget(const BarcodeBottomSheetPreview());
    await tester.pumpAndSettle();
    expect(find.byType(BarcodeBottomSheetPreview), findsOneWidget);
  });
}

