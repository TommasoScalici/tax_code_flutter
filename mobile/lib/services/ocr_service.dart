import 'package:logger/logger.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/services/card_parser_service.dart';
import 'google_vision_service.dart';

abstract class OCRServiceAbstract {
  Future<Contact?> performCardOCR(String base64Image);
}

class OCRService implements OCRServiceAbstract {
  final GoogleVisionServiceAbstract _visionService;
  final CardParserServiceAbstract _parserService;
  final Logger _logger;

  OCRService({
    required GoogleVisionServiceAbstract visionService,
    required CardParserServiceAbstract parserService,
    required Logger logger,
  }) : _visionService = visionService,
       _parserService = parserService,
       _logger = logger;

  @override
  Future<Contact?> performCardOCR(String base64Image) async {
    _logger.i('Starting OCR process...');
    
    final rawText = await _visionService.getTextFromImage(base64Image);

    if (rawText == null || rawText.isEmpty) {
      _logger.w('No text returned from Vision API.');
      return null;
    }
    
    final contact = _parserService.parseText(rawText);
    
    if (contact == null) {
      _logger.w('Failed to parse contact information from OCR text.');
      return null;
    }
    
    _logger.i('OCR process completed successfully.');
    return contact;
  }
}