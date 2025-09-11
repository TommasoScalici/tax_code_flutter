import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';

abstract class GeminiServiceAbstract {
  /// Calls the backend to extract data and returns it as form data.
  Future<ScannedData?> extractDataFromDocument(String base64Image);
}

class GeminiService implements GeminiServiceAbstract {
  final FirebaseFunctions _functions;
  final Logger _logger;

  GeminiService({required FirebaseFunctions functions, required Logger logger})
    : _functions = functions,
      _logger = logger;

  @override
  Future<ScannedData?> extractDataFromDocument(String base64Image) async {
    _logger.i("Calling 'extractDataFromDocument' Firebase Function.");
    try {
      final callable = _functions.httpsCallable('extractDataFromDocument');
      final result = await callable.call<Map<String, dynamic>>({
        'image': base64Image,
      });

      _logger.i('Successfully received data from Gemini Function.');

      final correctlyTypedData = Map<String, dynamic>.from(result.data);
      return ScannedData.fromJson(correctlyTypedData);
    } on FirebaseFunctionsException catch (e, s) {
      _logger.e(
        'Firebase Function failed: ${e.code} - ${e.message}',
        error: e,
        stackTrace: s,
      );
      return null;
    } catch (e, s) {
      _logger.e(
        'An unexpected error occurred while calling the Gemini service.',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }
}
