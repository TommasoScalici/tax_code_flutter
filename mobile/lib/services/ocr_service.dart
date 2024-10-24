import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';
import 'package:uuid/uuid.dart';

class OCRService {
  late Logger _logger;
  ServiceAccountCredentials? _credentials;

  OCRService(BuildContext context) {
    _logger = context.read<AppState>().logger;
  }

  Future<void> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      var jsonString = remoteConfig.getString('tax_code_flutter_vision');

      if (jsonString.isEmpty) {
        _logger.w('Remote config string for credentials is empty');
        return;
      }

      _credentials = ServiceAccountCredentials.fromJson(jsonString);
    } on Exception catch (e) {
      _logger.e('Error initializing OCR service: $e');
    }
  }

  Future<vision.BatchAnnotateImagesResponse?> analyzeImage(
      String base64Image) async {
    try {
      if (_credentials == null) {
        _logger.e('Credentials not loaded. Call initialize() first.');
      }

      final authClient = await clientViaServiceAccount(
        _credentials!,
        [vision.VisionApi.cloudVisionScope],
      );

      final visionApi = vision.VisionApi(authClient);
      final feature = vision.Feature(type: 'TEXT_DETECTION');
      final image = vision.Image(content: base64Image);
      final images = visionApi.images;

      final request =
          vision.AnnotateImageRequest(image: image, features: [feature]);
      final batchRequest =
          vision.BatchAnnotateImagesRequest(requests: [request]);
      final response = await images.annotate(batchRequest);

      return response;
    } catch (e) {
      _logger.e('Error during the image analysis: $e');
    }

    return null;
  }

  Future<Contact?> performCardOCR(String base64Image) async {
    final response = await analyzeImage(base64Image);

    if (response == null ||
        response.responses == null ||
        response.responses!.isEmpty) {
      _logger.w('No valid responses from OCR analysis.');
      return null;
    }

    final annotations = response.responses![0].fullTextAnnotation;
    if (annotations == null || annotations.text == null) {
      _logger.w('No text detected in the image.');
      return null;
    }

    final text = annotations.text;

    String? firstName;
    String? lastName;
    String? gender;
    Birthplace birthPlace = Birthplace(name: '', state: '');
    DateTime? birthDate;

    if (text != null) {
      final lines = text.split('\n');

      for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim();

        if (line.contains('Nome')) {
          firstName = _extractSimpleStringValue(lines, 'Nome', i);
        } else if (line.contains('NOME/NAME')) {
          firstName = _extractSimpleStringValue(lines, 'NOME/NAME', i);
        } else if (line.contains('Cognome')) {
          lastName = _extractSimpleStringValue(lines, 'Cognome', i);
        } else if (line.contains('COGNOME/SURNAME')) {
          lastName = _extractSimpleStringValue(lines, 'COGNOME/SURNAME', i);
        } else if (line.contains('Sesso')) {
          gender = _extractSimpleStringValue(lines, 'Sesso', i);
        } else if (line.contains('SEX')) {
          gender = _extractSimpleStringValue(lines, 'SEX', i);
        } else if (line.contains('di nascita') && birthPlace.name.isEmpty) {
          birthPlace.name = _extractSimpleStringValue(lines, 'di nascita', i);
        } else if (line.contains('Luogo') && birthPlace.name.isEmpty) {
          birthPlace.name = _extractSimpleStringValue(lines, 'Luogo', i);
        } else if (line.contains('Provincia') && birthPlace.state.isEmpty) {
          birthPlace.state = _extractSimpleStringValue(lines, 'Provincia', i);
        } else if (line.contains('Data') && birthDate == null) {
          birthDate = _extractBirthDate(line, 'Data');
        } else if (line.contains('PLACE AND DATE OF BIRTH')) {
          var parts = lines[i + 1].split(' ');

          if (parts.length == 3) {
            var province = parts[1].replaceAll('(', '').replaceAll(')', '');
            var date = parts[2].replaceAll('.', '/');
            var format = DateFormat('dd/MM/yyyy');
            var dateTime = format.parse(date);

            birthPlace.state = province;
            birthPlace.name = parts[0];
            birthDate = dateTime;
          }
        }
      }
    }

    if (firstName != null && lastName != null && gender != null) {
      return Contact(
          id: Uuid().v4(),
          firstName: firstName.toCapitalCase(),
          lastName: lastName.toCapitalCase(),
          gender: gender,
          taxCode: '',
          birthPlace: Birthplace(
            name: birthPlace.name.toCapitalCase(),
            state: birthPlace.name.toUpperCase(),
          ),
          birthDate: birthDate ?? DateTime.now(),
          listIndex: 0);
    }

    _logger.w('Failed to extract necessary contact information.');
    return null;
  }

  DateTime? _extractBirthDate(String line, String key) {
    var parts = line.split(key);

    if (parts.length > 1 && parts[1].isNotEmpty) {
      var format = DateFormat("dd/MM/yyyy");
      var date = format.tryParse(parts[1].trim(), true);
      return date;
    }

    return null;
  }

  String _extractSimpleStringValue(List<String> lines, String key, int index) {
    var line = lines[index].trim();
    var parts = line.split(key);

    if (parts.length > 1 && parts[1].isNotEmpty) {
      if (parts[1].trim() == parts[1].trim().toUpperCase()) {
        return parts[1].trim();
      }
    } else if (index < lines.length - 1) {
      if (lines[index + 1].trim() == lines[index + 1].trim().toUpperCase()) {
        return lines[index + 1].trim();
      }
    }

    return '';
  }
}
