import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/models/birthplace.dart';

/// Defines the contract for a service that provides birthplace data.
abstract class BirthplaceServiceAbstract {
  Future<List<Birthplace>> loadBirthplaces({
    void Function(double? progress, String step)? onProgress,
  });
}

/// The concrete implementation of [BirthplaceService] that loads data
/// from Firebase Storage and caches it locally.
class BirthplaceService implements BirthplaceServiceAbstract {
  final Logger _logger;
  final String _storagePath;

  BirthplaceService({
    required Logger logger,
    String storagePath = 'public/cities.json',
  }) : _logger = logger,
       _storagePath = storagePath;

  @override
  Future<List<Birthplace>> loadBirthplaces({
    void Function(double? progress, String step)? onProgress,
  }) async {
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final localFile = File('${cacheDir.path}/cities.json');

      bool shouldDownload = true;
      if (await localFile.exists()) {
        shouldDownload = false;
        if (await localFile.length() == 0) {
          shouldDownload = true;
        }
      }

      if (shouldDownload) {
        _logger.i('Downloading cities.json from Firebase Storage...');
        final ref = FirebaseStorage.instance.ref(_storagePath);

        try {
          onProgress?.call(null, 'downloading');
          final downloadTask = ref.writeToFile(localFile);
          downloadTask.snapshotEvents.listen((taskSnapshot) {
            if (taskSnapshot.state == TaskState.running &&
                taskSnapshot.totalBytes > 0) {
              onProgress?.call(
                taskSnapshot.bytesTransferred / taskSnapshot.totalBytes,
                'downloading',
              );
            }
          });
          await downloadTask;
          _logger.i('Downloaded and cached cities.json successfully.');
        } on FirebaseException catch (e) {
          _logger.w(
            'FirebaseStorage download failed: ${e.code}. Generating via Cloud Function...',
          );

          if (e.code == 'object-not-found') {
            onProgress?.call(null, 'generating');
            // The JSON does not exist on storage yet, let's call the function
            try {
              final result = await FirebaseFunctions.instance
                  .httpsCallable('generateCitiesJson')
                  .call();
              if (result.data['success'] == true) {
                // Now try nicely to download it again
                _logger.i(
                  'Cloud function completed, downloading newly generated file...',
                );
                onProgress?.call(null, 'downloading');
                final downloadTask = ref.writeToFile(localFile);
                downloadTask.snapshotEvents.listen((taskSnapshot) {
                  if (taskSnapshot.state == TaskState.running &&
                      taskSnapshot.totalBytes > 0) {
                    onProgress?.call(
                      taskSnapshot.bytesTransferred / taskSnapshot.totalBytes,
                      'downloading',
                    );
                  }
                });
                await downloadTask;
              }
            } catch (fnErr) {
              _logger.e(
                'Failed to generate cities.json via Cloud Function.',
                error: fnErr,
              );
              // Fallback to bundled asset if we hit absolute worst-case scenario
              // Wait, we deprecated the asset, but let's see. If the user deleted it, it will throw.
              // So we just throw Exception.
              throw Exception(
                'Could not fetch or generate cities.json from Firebase',
              );
            }
          } else {
            throw Exception('FirebaseStorage Error: ${e.message}');
          }
        }
      } else {
        _logger.i('Using locally cached cities.json.');
      }

      if (!await localFile.exists()) {
        throw Exception('cities.json is not available locally.');
      }

      onProgress?.call(null, 'parsing');
      final jsonString = await localFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map<Birthplace>((json) => Birthplace.fromJson(json))
          .toList();
    } catch (e, s) {
      _logger.e(
        'Failed to load or parse birthplaces.',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }
}
