import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
}

/// The concrete implementation of [BirthplaceService] that loads data
/// from Firebase Storage in the background and uses local fallback assets on first launch.
class BirthplaceService implements BirthplaceServiceAbstract {
  final Logger _logger;
  final String _storagePath;

  @override
  final ValueNotifier<double?> downloadProgress = ValueNotifier(null);
  @override
  final ValueNotifier<String?> downloadStep = ValueNotifier(null);

  List<Birthplace>? _cachedBirthplaces;
  Future<List<Birthplace>>? _initializationFuture;

  BirthplaceService({
    required Logger logger,
    String storagePath = 'public/birthplaces.json',
  }) : _logger = logger,
       _storagePath = storagePath;

  @override
  Future<List<Birthplace>> loadBirthplaces() async {
    if (_cachedBirthplaces != null) return _cachedBirthplaces!;
    _initializationFuture ??= _performLoad();
    return _initializationFuture!;
  }

  Future<List<Birthplace>> _performLoad() async {
    downloadStep.value = 'checking';
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
        downloadStep.value = 'parsing';
        final jsonString = await localFile.readAsString();
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        var parsedList = jsonList
            .map<Birthplace>(
              (dynamic json) =>
                  Birthplace.fromJson(json as Map<String, dynamic>),
            )
            .toList();

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
            final newJsonList = jsonDecode(newJsonString) as List<dynamic>;
            parsedList = newJsonList
                .map<Birthplace>(
                  (dynamic json) =>
                      Birthplace.fromJson(json as Map<String, dynamic>),
                )
                .toList();
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

      downloadStep.value = null;
      downloadProgress.value = null;
      return _cachedBirthplaces ?? [];
    } on Object catch (e, s) {
      _logger.e(
        'Failed to load or parse birthplaces.',
        error: e,
        stackTrace: s,
      );
      downloadStep.value = null;
      downloadProgress.value = null;
      _initializationFuture = null; // Allow retry on failure
      return [];
    }
  }

  void _triggerBackgroundUpdate(File localFile) {
    scheduleMicrotask(() async {
      try {
        final ref = FirebaseStorage.instance.ref(_storagePath);
        bool shouldDownload = true;

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

        if (shouldDownload) {
          _logger.i(
            'Background: Downloading updated birthplaces.json from Firebase Storage...',
          );
          final tempFile = File('${localFile.path}.tmp');

          try {
            final downloadTask = ref.writeToFile(tempFile);
            downloadTask.snapshotEvents.listen((taskSnapshot) {
              if (taskSnapshot.state == TaskState.running &&
                  taskSnapshot.totalBytes > 0) {
                downloadProgress.value =
                    taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
              }
            });
            await downloadTask;
            if (await tempFile.exists()) {
              await tempFile.rename(localFile.path);
              _logger.i(
                'Background: Local birthplaces.json cache updated successfully.',
              );
            }
          } finally {
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          }
        }
      } on Object catch (e) {
        _logger.w('Background update of birthplaces.json failed: $e');
      }
    });
  }
}
