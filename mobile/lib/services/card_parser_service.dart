import 'dart:math';
import 'package:change_case/change_case.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:uuid/uuid.dart';

part './parsers/mixins/cie_parser_mixin.dart';
part './parsers/mixins/parser_helpers_mixin.dart';
part './parsers/mixins/ts_parser_mixin.dart';

enum CardType { cie, ts, unknown }

abstract class CardParserServiceAbstract {
  Contact? parseText(String rawText);
}

class CardParserService extends CardParserServiceAbstract
    with _ParserHelpersMixin, _CieParserMixin, _TsParserMixin {
  @override
  final Logger logger;

  CardParserService({required this.logger});

  @override
  Contact? parseText(String rawText) {
    final lines = _preProcessText(rawText);
    if (lines.isEmpty) {
      logger.w('OCR raw text is empty after cleaning.');
      return null;
    }

    final cardType = _detectCardType(lines);

    // Uncomment for debugging
    // logger.i('--- Detected Card Type ---');
    // logger.i('Detected card type: $cardType');
    // logger.i('Raw Text:\n$rawText');

    switch (cardType) {
      case CardType.cie:
        return parseCIE(lines);
      case CardType.ts:
        return parseTS(lines);
      case CardType.unknown:
        logger.w('Could not determine card type.');
        return null;
    }
  }
}
