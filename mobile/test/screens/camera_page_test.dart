import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tax_code_flutter/controllers/camera_page_controller.dart';
import 'package:tax_code_flutter/screens/camera_page.dart';

import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_setup.dart';

class MockCameraPageController extends Mock implements CameraPageController {}

void main() {
  setUpAll(setupTests);

  late MockCameraPageController mockController;
  late MockPermissionService mockPermissionService;
  late MockCameraService mockCameraService;

  setUp(() {
    mockController = MockCameraPageController();
    mockPermissionService = MockPermissionService();
    mockCameraService = MockCameraService();

    when(() => mockController.addListener(any())).thenAnswer((_) {});
    when(() => mockController.removeListener(any())).thenAnswer((_) {});
    when(() => mockController.openAppSettingsHandler()).thenAnswer((_) async => true);
  });

  group('CameraPage Widget Tests', () {
    testWidgets('displays loading indicator and AppBar when status is initializing', (
      tester,
    ) async {
      when(() => mockController.status).thenReturn(CameraStatus.initializing);

      await pumpApp(
        tester,
        CameraPage(controller: mockController),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Scan Card'), findsOneWidget);
    });

    testWidgets(
      'displays permission denied view with no_photography icon, text, and settings button',
      (tester) async {
        when(() => mockController.status).thenReturn(CameraStatus.permissionDenied);

        await pumpApp(
          tester,
          CameraPage(controller: mockController),
        );

        expect(find.byIcon(Icons.no_photography), findsOneWidget);
        expect(
          find.text(
            'To scan cards, this app needs access to your camera. Please go to your device settings and grant camera permission.',
          ),
          findsOneWidget,
        );
        expect(find.text('Open Settings'), findsOneWidget);

        // Tap the Open Settings button
        await tester.tap(find.text('Open Settings'));
        await tester.pumpAndSettle();

        verify(() => mockController.openAppSettingsHandler()).called(1);
      },
    );

    testWidgets('displays generic error text when status is error', (tester) async {
      when(() => mockController.status).thenReturn(CameraStatus.error);

      await pumpApp(
        tester,
        CameraPage(controller: mockController),
      );

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'integrates with default CameraPage creation when permission is denied',
      (tester) async {
        when(
          () => mockPermissionService.requestCameraPermission(),
        ).thenAnswer((_) async => false);

        await pumpApp(
          tester,
          const CameraPage(),
          mockPermissionService: mockPermissionService,
          mockCameraService: mockCameraService,
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.no_photography), findsOneWidget);
        expect(find.text('Open Settings'), findsOneWidget);
      },
    );

    testWidgets(
      'integrates with default CameraPage creation and transitions to error when no cameras are available',
      (tester) async {
        when(
          () => mockPermissionService.requestCameraPermission(),
        ).thenAnswer((_) async => true);
        when(
          () => mockCameraService.getAvailableCameras(),
        ).thenAnswer((_) async => []);

        await pumpApp(
          tester,
          const CameraPage(),
          mockPermissionService: mockPermissionService,
          mockCameraService: mockCameraService,
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
      },
    );
  });
}
