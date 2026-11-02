import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter_wear_os/widgets/previews/previews.dart';

void main() {
  group('Wear OS Previews Suite', () {
    testWidgets('pumps WearContactsListPreview without error', (tester) async {
      await tester.pumpWidget(const WearContactsListPreview());
      await tester.pumpAndSettle();
      expect(find.byType(WearContactsListPreview), findsOneWidget);
    });

    testWidgets('pumps WearBarcodePagePreview without error', (tester) async {
      await tester.pumpWidget(const WearBarcodePagePreview());
      await tester.pumpAndSettle();
      expect(find.byType(WearBarcodePagePreview), findsOneWidget);
    });

    testWidgets('pumps WearContactCardPreview without error', (tester) async {
      await tester.pumpWidget(const WearContactCardPreview());
      await tester.pumpAndSettle();
      expect(find.byType(WearContactCardPreview), findsOneWidget);
    });

    testWidgets('pumps WearConfirmationDialogPreview without error', (
      tester,
    ) async {
      await tester.pumpWidget(const WearConfirmationDialogPreview());
      await tester.pumpAndSettle();
      expect(find.byType(WearConfirmationDialogPreview), findsOneWidget);
    });

    testWidgets('pumps WearAuthGatePreview without error', (tester) async {
      await tester.pumpWidget(const WearAuthGatePreview());
      await tester.pumpAndSettle();
      expect(find.byType(WearAuthGatePreview), findsOneWidget);
    });

    testWidgets('toggles shape between round and square in WearPreviewShell', (
      tester,
    ) async {
      await tester.pumpWidget(const WearContactsListPreview());
      await tester.pumpAndSettle();

      // Tap shape toggle chip
      final shapeChip = find.widgetWithText(ActionChip, 'Round (200dp)');
      expect(shapeChip, findsOneWidget);

      await tester.tap(shapeChip);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ActionChip, 'Square (200dp)'), findsOneWidget);
    });

    testWidgets('toggles locale between IT and EN in WearPreviewShell', (
      tester,
    ) async {
      await tester.pumpWidget(const WearContactsListPreview());
      await tester.pumpAndSettle();

      // Tap locale toggle chip
      final itChip = find.widgetWithText(ActionChip, 'IT');
      expect(itChip, findsOneWidget);

      await tester.tap(itChip);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ActionChip, 'EN'), findsOneWidget);
    });
  });
}
