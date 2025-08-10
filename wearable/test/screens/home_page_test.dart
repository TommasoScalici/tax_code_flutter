// test/screens/home_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/screens/home_page.dart';
import 'package:tax_code_flutter_wear_os/widgets/contact_list.dart';

import 'home_page_test.mocks.dart';

@GenerateMocks([AppState])
void main() {
  late MockAppState mockAppState;

  setUp(() {
    mockAppState = MockAppState();
    when(mockAppState.contacts).thenReturn([]);
    when(mockAppState.isLoading).thenReturn(false);
  });

  testWidgets('HomePage should build its children and have correct properties',
      (WidgetTester tester) async {
    /// Arrange: Pump the HomePage widget with the necessary provider.
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: mockAppState,
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    /// Assert: Verify the presence of child widgets.

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Padding), findsOneWidget);
    expect(find.byType(ContactList), findsOneWidget);

    /// Assert: Verify widget properties.

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.black);

    final padding = tester.widget<Padding>(find.byType(Padding));
    expect(padding.padding, const EdgeInsets.all(20.0));
  });
}
