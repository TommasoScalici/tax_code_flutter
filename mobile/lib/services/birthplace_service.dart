import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
/// from Firebase Storage and caches it locally.
class BirthplaceService implements BirthplaceServiceAbstract {
  final FirebaseFunctions _functions;
  final Logger _logger;
  final String _storagePath;

  @override
  final ValueNotifier<double?> downloadProgress = ValueNotifier(null);
  @override
  final ValueNotifier<String?> downloadStep = ValueNotifier(null);

  List<Birthplace>? _cachedBirthplaces;
  Future<List<Birthplace>>? _initializationFuture;

  BirthplaceService({
    required FirebaseFunctions functions,
    required Logger logger,
    String storagePath = 'public/birthplaces.json',
  }) : _functions = functions,
       _logger = logger,
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

      final ref = FirebaseStorage.instance.ref(_storagePath);
      bool shouldDownload = true;

      try {
        if (await localFile.exists() && await localFile.length() > 0) {
          // Check if server version is newer
          final metadata = await ref.getMetadata();
          final serverLastModified = metadata.updated;
          final localLastModified = await localFile.lastModified();

          if (serverLastModified != null &&
              !serverLastModified.isAfter(localLastModified)) {
            shouldDownload = false;
          }
        }
      } catch (e) {
        // If metadata check fails (e.g. offline), use cache if it exists
        if (await localFile.exists() && await localFile.length() > 0) {
          shouldDownload = false;
          _logger.w('Could not check for updates, using cached file: $e');
        }
      }

      if (shouldDownload) {
        _logger.i('Downloading/Updating birthplaces.json from Firebase Storage...');

        try {
          downloadStep.value = 'downloading';
          final downloadTask = ref.writeToFile(localFile);
          downloadTask.snapshotEvents.listen((taskSnapshot) {
            if (taskSnapshot.state == TaskState.running &&
                taskSnapshot.totalBytes > 0) {
              downloadProgress.value =
                  taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
            }
          });
          await downloadTask;
          _logger.i('Downloaded and cached birthplaces.json successfully.');
        } on FirebaseException catch (e) {
          _logger.w(
            'FirebaseStorage download failed: ${e.code}. Generating via Cloud Function...',
          );

          if (e.code == 'object-not-found') {
            downloadStep.value = 'generating';
            downloadProgress.value = null;
            // The JSON does not exist on storage yet, let's call the function
            try {
              final result = await _functions
                  .httpsCallable('updateBirthplaces')
                  .call();
              if (result.data != null && result.data['success'] == true) {
                // Now try nicely to download it again
                _logger.i(
                  'Cloud function completed, downloading newly generated file...',
                );
                downloadStep.value = 'downloading';
                final downloadTask = ref.writeToFile(localFile);
                downloadTask.snapshotEvents.listen((taskSnapshot) {
                  if (taskSnapshot.state == TaskState.running &&
                      taskSnapshot.totalBytes > 0) {
                    downloadProgress.value =
                        taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
                  }
                });
                await downloadTask;
              }
            } catch (fnErr) {
              _logger.e(
                'Failed to generate birthplaces.json via Cloud Function.',
                error: fnErr,
              );
              throw Exception(
                'Could not fetch or generate birthplaces.json from Firebase',
              );
            }
          } else {
            throw Exception('FirebaseStorage Error: ${e.message}');
          }
        }
      } else {
        _logger.i('Using locally cached birthplaces.json.');
      }

      if (!await localFile.exists()) {
        throw Exception('birthplaces.json is not available locally.');
      }

      downloadStep.value = 'parsing';
      downloadProgress.value = null;
      final jsonString = await localFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedBirthplaces = jsonList
          .map<Birthplace>((json) => Birthplace.fromJson(json))
          .toList();
      
      downloadStep.value = null;
      downloadProgress.value = null;
      return _cachedBirthplaces!;
    } catch (e, s) {
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
}
