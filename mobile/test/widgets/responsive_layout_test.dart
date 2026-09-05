import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

void main() {
  group('ResponsiveLayout Widget Tests', () {
    testWidgets('renders child correctly on mobile screen size',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              child: Text('Mobile Content'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Content'), findsOneWidget);
      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('constrains width to maxWidth on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              maxWidth: 500,
              child: SizedBox(
                width: double.infinity,
                height: 200,
                key: Key('content-box'),
              ),
            ),
          ),
        ),
      );

      final renderBox =
          tester.renderObject(find.byKey(const Key('content-box'))) as RenderBox;
      expect(renderBox.size.width, equals(500.0));
    });

    testWidgets('builder constructor provides isWide flag accurately',
        (tester) async {
      // Mobile screen: width 400 (< 600)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool? wasWide;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout.builder(
              builder: (context, constraints, isWide) {
                wasWide = isWide;
                return Text(isWide ? 'Wide Mode' : 'Compact Mode');
              },
            ),
          ),
        ),
      );

      expect(wasWide, isFalse);
      expect(find.text('Compact Mode'), findsOneWidget);

      // Tablet / wide screen: width 800 (>= 600)
      tester.view.physicalSize = const Size(800, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout.builder(
              builder: (context, constraints, isWide) {
                wasWide = isWide;
                return Text(isWide ? 'Wide Mode' : 'Compact Mode');
              },
            ),
          ),
        ),
      );

      expect(wasWide, isTrue);
      expect(find.text('Wide Mode'), findsOneWidget);
    });

    testWidgets('utility helpers report correct classifications',
        (tester) async {
      tester.view.physicalSize = const Size(700, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(ResponsiveLayout.isMobile(capturedContext), isFalse);
      expect(ResponsiveLayout.isTablet(capturedContext), isTrue);
      expect(ResponsiveLayout.isWide(capturedContext), isTrue);
    });

    testWidgets('respects useSafeArea flag', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              useSafeArea: false,
              child: Text('No SafeArea'),
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              useSafeArea: true,
              child: Text('With SafeArea'),
            ),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
