import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/services/birthplace_service.dart';

class MockLogger extends Mock implements Logger {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockFullMetadata extends Mock implements FullMetadata {}

class FakeDownloadTask extends Fake implements DownloadTask {
  @override
  Stream<TaskSnapshot> get snapshotEvents => const Stream.empty();

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) {
    return Future.value(MockTaskSnapshot()).then(onValue, onError: onError);
  }
}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLogger mockLogger;
  late MockFirebaseStorage mockStorage;
  late MockReference mockRef;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(File('dummy.tmp'));
  });

  setUp(() async {
    mockLogger = MockLogger();
    mockStorage = MockFirebaseStorage();
    mockRef = MockReference();

    tempDir = await Directory.systemTemp.createTemp('birthplaces_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );

    when(() => mockStorage.ref(any())).thenReturn(mockRef);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('BirthplaceService', () {
    test('loads birthplaces from local cache file when present', () async {
      final localFile = File('${tempDir.path}/birthplaces.json');
      const testJson =
          '[{"name":"Roma","state":"RM","code":"H501"},{"name":"Milano","state":"MI","code":"F205"}]';
      await localFile.writeAsString(testJson);

      // Return older timestamp from storage so background update does not download
      final metadata = MockFullMetadata();
      when(() => metadata.updated).thenReturn(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      when(() => mockRef.getMetadata()).thenAnswer((_) async => metadata);

      final service = BirthplaceService(
        logger: mockLogger,
        storage: mockStorage,
      );

      final result = await service.loadBirthplaces();

      expect(result.length, 2);
      expect(result.first.name, 'Roma');
      expect(result.first.code, 'H501');
      expect(result.last.name, 'Milano');
      expect(result.last.code, 'F205');

      // Second call returns from memory cache immediately
      final cachedResult = await service.loadBirthplaces();
      expect(identical(result, cachedResult), isTrue);
    });

    test('recovers and overwrites when cache contains missing codes', () async {
      final localFile = File('${tempDir.path}/birthplaces.json');
      // All codes are empty
      const badJson =
          '[{"name":"Roma","state":"RM","code":""},{"name":"Milano","state":"MI","code":""}]';
      await localFile.writeAsString(badJson);

      // Mock rootBundle asset fallback
      const fallbackAssetJson =
          '[{"name":"Roma","state":"RM","code":"H501"}]';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final byteData = ByteData.view(
          Uint8List.fromList(fallbackAssetJson.codeUnits).buffer,
        );
        return byteData;
      });

      final metadata = MockFullMetadata();
      when(() => metadata.updated).thenReturn(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      when(() => mockRef.getMetadata()).thenAnswer((_) async => metadata);

      final service = BirthplaceService(
        logger: mockLogger,
        storage: mockStorage,
      );

      final result = await service.loadBirthplaces();

      expect(result.length, 1);
      expect(result.first.name, 'Roma');
      expect(result.first.code, 'H501');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('background download updates local file and refreshes in-memory cache', () async {
      final localFile = File('${tempDir.path}/birthplaces.json');
      const initialJson =
          '[{"name":"Roma","state":"RM","code":"H501"}]';
      await localFile.writeAsString(initialJson);

      // Server has newer timestamp
      final metadata = MockFullMetadata();
      when(() => metadata.updated).thenReturn(
        DateTime.now().add(const Duration(days: 1)),
      );
      when(() => mockRef.getMetadata()).thenAnswer((_) async => metadata);

      const updatedJson =
          '[{"name":"Roma","state":"RM","code":"H501"},{"name":"Napoli","state":"NA","code":"F839"}]';

      final fakeTask = FakeDownloadTask();
      when(() => mockRef.writeToFile(any())).thenAnswer((invocation) {
        final targetFile = invocation.positionalArguments[0] as File;
        targetFile.writeAsStringSync(updatedJson);
        return fakeTask;
      });

      final service = BirthplaceService(
        logger: mockLogger,
        storage: mockStorage,
      );

      final initialResult = await service.loadBirthplaces();
      expect(initialResult.length, 1);

      // Allow background microtask to execute
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Check that in-memory cache was updated
      final updatedResult = await service.loadBirthplaces();
      expect(updatedResult.length, 2);
      expect(updatedResult.any((b) => b.name == 'Napoli'), isTrue);
    });
  });
}
