import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/models/birthplace.dart';

/// Defines the contract for a service that provides birthplace data.
abstract class BirthplaceServiceAbstract {
  ValueNotifier<double?> get downloadProgress;
  ValueNotifier<String?> get downloadStep;
  Future<List<Birthplace>> loadBirthplaces();
  void dispose();
}

/// Parses raw JSON string into a list of [Birthplace] objects.
List<Birthplace> _parseBirthplacesJson(String jsonString) {
  final jsonList = jsonDecode(jsonString) as List<dynamic>;
  return jsonList
      .map<Birthplace>(
        (dynamic json) =>
            Birthplace.fromJson(json as Map<String, dynamic>),
      )
      .toList();
}

/// Helper to execute JSON parsing in a separate isolate without capturing class instance.
Future<List<Birthplace>> _parseBirthplacesInIsolate(String jsonString) {
  return Isolate.run(() => _parseBirthplacesJson(jsonString));
}

/// The concrete implementation of [BirthplaceService] that loads data
/// from Firebase Storage in the background and uses local fallback assets on first launch.
class BirthplaceService implements BirthplaceServiceAbstract {
  final Logger _logger;
  final FirebaseStorage _storage;
  final String _storagePath;

  @override
  final ValueNotifier<double?> downloadProgress = ValueNotifier(null);
  @override
  final ValueNotifier<String?> downloadStep = ValueNotifier(null);

  List<Birthplace>? _cachedBirthplaces;
  Future<List<Birthplace>>? _initializationFuture;
  Future<void>? _backgroundUpdateFuture;
  StreamSubscription<TaskSnapshot>? _downloadSubscription;
  bool _isDisposed = false;

  @visibleForTesting
  Future<void>? get backgroundUpdateFuture => _backgroundUpdateFuture;

  @visibleForTesting
  bool get isDisposed => _isDisposed;

  BirthplaceService({
    required Logger logger,
    FirebaseStorage? storage,
    String storagePath = 'public/birthplaces.json',
  })  : _logger = logger,
        _storage = storage ?? FirebaseStorage.instance,
        _storagePath = storagePath;

  void _setDownloadProgress(double? value) {
    if (!_isDisposed) {
      downloadProgress.value = value;
    }
  }

  void _setDownloadStep(String? value) {
    if (!_isDisposed) {
      downloadStep.value = value;
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    unawaited(_downloadSubscription?.cancel());
    _downloadSubscription = null;
    downloadProgress.dispose();
    downloadStep.dispose();
  }

  @override
  Future<List<Birthplace>> loadBirthplaces() async {
    if (_cachedBirthplaces != null) return _cachedBirthplaces!;
    _initializationFuture ??= _performLoad();
    return await _initializationFuture!;
  }

  Future<List<Birthplace>> _performLoad() async {
    _setDownloadStep('checking');
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final localFile = File('${cacheDir.path}/birthplaces.json');

      // Copy from asset fallback if cache is empty
      if (!await localFile.exists() || await localFile.length() == 0) {
        _logger.i('Cache empty. Loading fallback birthplaces from assets...');
        try {
          final assetContent = await rootBundle.loadString(
            'assets/birthplaces.json',
          );
          await localFile.writeAsString(assetContent);
          _logger.i('Fallback birthplaces copied to cache.');
        } on Object catch (assetErr) {
          _logger.e(
            'Failed to load fallback birthplaces from assets: $assetErr',
          );
        }
      }

      // Read cache immediately for instant startup
      if (await localFile.exists() && await localFile.length() > 0) {
        _setDownloadStep('parsing');
        final jsonString = await localFile.readAsString();
        var parsedList = await _parseBirthplacesInIsolate(jsonString);

        // Check if the cache contains Belfiore codes (at least check the first few elements)
        final missingCodes = parsedList.isNotEmpty &&
            parsedList.take(50).every((b) => b.code.isEmpty);

        if (missingCodes) {
          _logger.w(
            'Outdated birthplace cache detected (no Belfiore codes). Overwriting with asset fallback...',
          );
          try {
            final assetContent =
                await rootBundle.loadString('assets/birthplaces.json');
            await localFile.writeAsString(assetContent);

            final newJsonString = await localFile.readAsString();
            parsedList = await _parseBirthplacesInIsolate(newJsonString);
            _logger.i('Fallback birthplaces copied to cache and re-loaded.');
          } on Object catch (assetErr) {
            _logger.e('Failed to overwrite with asset fallback: $assetErr');
          }
        }

        _cachedBirthplaces = parsedList;
        _logger.i(
          'Successfully loaded ${_cachedBirthplaces!.length} birthplaces from local cache.',
        );
      }

      // Trigger background update from Firebase Storage without awaiting it
      _triggerBackgroundUpdate(localFile);

      _setDownloadStep(null);
      _setDownloadProgress(null);
      return _cachedBirthplaces ?? [];
    } on Object catch (e, s) {
      _logger.e(
        'Failed to load or parse birthplaces.',
        error: e,
        stackTrace: s,
      );
      _setDownloadStep(null);
      _setDownloadProgress(null);
      _initializationFuture = null; // Allow retry on failure
      return [];
    }
  }

  void _triggerBackgroundUpdate(File localFile) {
    _backgroundUpdateFuture = _performBackgroundUpdate(localFile);
  }

  Future<void> _performBackgroundUpdate(File localFile) async {
    try {
      final ref = _storage.ref(_storagePath);
      var shouldDownload = true;

      try {
        final metadata = await ref.getMetadata();
        final serverLastModified = metadata.updated;
        final localLastModified = await localFile.lastModified();

        if (serverLastModified != null &&
            !serverLastModified.isAfter(localLastModified)) {
          shouldDownload = false;
        }
      } on Object {
        // Offline or storage metadata read error, keep local cache
        shouldDownload = false;
      }

      if (_isDisposed) return;

      if (shouldDownload) {
        _logger.i(
          'Background: Downloading updated birthplaces.json from Firebase Storage...',
        );
        final tempFile = File('${localFile.path}.tmp');

        try {
          final downloadTask = ref.writeToFile(tempFile);
          _setDownloadStep('downloading');

          await _downloadSubscription?.cancel();
          _downloadSubscription = downloadTask.snapshotEvents.listen(
            (taskSnapshot) {
              if (!_isDisposed &&
                  taskSnapshot.state == TaskState.running &&
                  taskSnapshot.totalBytes > 0) {
                _setDownloadProgress(
                  taskSnapshot.bytesTransferred / taskSnapshot.totalBytes,
                );
              }
            },
            onError: (Object error) {
              _logger.w('Download progress stream error: $error');
            },
          );

          await downloadTask;
          if (_isDisposed) return;

          if (await tempFile.exists()) {
            // Safe cross-platform copy & delete to prevent Windows OS Error 183
            await tempFile.copy(localFile.path);
            await tempFile.delete();
            _logger.i(
              'Background: Local birthplaces.json cache updated successfully.',
            );

            // Keep in-memory cache synchronized with background update
            try {
              final updatedJson = await localFile.readAsString();
              final updatedList = await _parseBirthplacesInIsolate(
                updatedJson,
              );
              if (!_isDisposed) {
                _cachedBirthplaces = updatedList;
                _logger.i(
                  'Background: Refreshed ${_cachedBirthplaces!.length} birthplaces in memory cache.',
                );
              }
            } on Object catch (cacheErr) {
              _logger.w(
                'Background: Failed to refresh in-memory cache: $cacheErr',
              );
            }
          }
        } finally {
          await _downloadSubscription?.cancel();
          _downloadSubscription = null;
          _setDownloadProgress(null);
          _setDownloadStep(null);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      }
    } on Object catch (e) {
      _logger.w('Background update of birthplaces.json failed: $e');
    }
  }
}
