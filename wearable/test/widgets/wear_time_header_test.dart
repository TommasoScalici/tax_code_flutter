import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tax_code_flutter_wear_os/core/theme/wear_theme.dart';
import 'package:tax_code_flutter_wear_os/widgets/wear_time_header.dart';

void main() {
  testWidgets('WearTimeHeader displays formatted time', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WearTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: WearTimeHeader(),
          ),
        ),
      ),
    );

    expect(find.byType(WearTimeHeader), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);

    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.data, isNotNull);
    expect(textWidget.data, isNotEmpty);
    // Should match time format (e.g. 12:34 or 12:34 PM)
    expect(textWidget.data, matches(r'\d{1,2}:\d{2}'));
  });
}
