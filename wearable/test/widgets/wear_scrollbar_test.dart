import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_scrollbar.dart';

void main() {
  const fadeKey = ValueKey('wear_scrollbar_fade');

  group('WearScrollbar Widget', () {
    testWidgets('renders child widget properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WearScrollbar(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('does not render CustomPaint scrollbar when content is not scrollable', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WearScrollbar(
                child: ListView(
                  children: const [
                    SizedBox(height: 50, child: Text('Short Item')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // CustomPaint/FadeTransition for the scrollbar should not be present
      expect(find.byKey(fadeKey), findsNothing);
    });

    testWidgets('displays curved scrollbar when scrolling scrollable content on round screen', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WearScrollbar(
                controller: controller,
                child: ListView.builder(
                  controller: controller,
                  itemCount: 20,
                  itemBuilder: (_, i) => SizedBox(
                    height: 40,
                    child: Text('Item $i'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Drag to trigger scrolling
      await tester.drag(find.text('Item 0'), const Offset(0, -100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // FadeTransition with fadeKey should now be rendered and visible
      expect(find.byKey(fadeKey), findsOneWidget);

      final fade = tester.widget<FadeTransition>(find.byKey(fadeKey));
      expect(fade.opacity.value, greaterThan(0.0));
    });

    testWidgets('auto-hides after autoHideDuration elapses', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WearScrollbar(
                controller: controller,
                autoHideDuration: const Duration(milliseconds: 500),
                child: ListView.builder(
                  controller: controller,
                  itemCount: 20,
                  itemBuilder: (_, i) => SizedBox(
                    height: 40,
                    child: Text('Item $i'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to trigger fade in
      await tester.drag(find.text('Item 0'), const Offset(0, -80));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final fadeVisible = tester.widget<FadeTransition>(find.byKey(fadeKey));
      expect(fadeVisible.opacity.value, greaterThan(0.0));

      // Advance past auto-hide duration (500ms) + reverse animation duration (300ms)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));

      final fadeHidden = tester.widget<FadeTransition>(find.byKey(fadeKey));
      expect(fadeHidden.opacity.value, 0.0);
    });

    testWidgets('paints in rectangular mode when isRound is false', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WearScrollbar(
                controller: controller,
                isRound: false,
                child: ListView.builder(
                  controller: controller,
                  itemCount: 20,
                  itemBuilder: (_, i) => SizedBox(
                    height: 40,
                    child: Text('Item $i'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(find.text('Item 0'), const Offset(0, -50));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(fadeKey), findsOneWidget);
    });

    testWidgets('responds to programmatic controller jumps (rotary crown)', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WearScrollbar(
                controller: controller,
                child: ListView.builder(
                  controller: controller,
                  itemCount: 20,
                  itemBuilder: (_, i) => SizedBox(
                    height: 40,
                    child: Text('Item $i'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Programmatic jump as done by rotary scroll event
      controller.jumpTo(100.0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(fadeKey), findsOneWidget);
      final fade = tester.widget<FadeTransition>(find.byKey(fadeKey));
      expect(fade.opacity.value, greaterThan(0.0));
    });
  });
}
