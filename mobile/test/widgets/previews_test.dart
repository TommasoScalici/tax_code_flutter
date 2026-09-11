import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/widgets/previews/contact_card_preview.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_header_preview.dart';
import 'package:tax_code_flutter/widgets/previews/dashboard_search_bar_preview.dart';
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
}

