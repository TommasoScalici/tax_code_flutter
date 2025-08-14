import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:shared/models/birthplace.dart';

/// Defines the contract for a service that provides birthplace data.
abstract class BirthplaceServiceAbstract {
  Future<List<Birthplace>> loadBirthplaces();
}

/// The concrete implementation of [BirthplaceService] that loads data
/// from a local JSON asset.
class BirthplaceService implements BirthplaceServiceAbstract {
  final Logger _logger;
  final String _assetPath;

  BirthplaceService({
    required Logger logger,
    String assetPath = 'assets/json/cities.json',
  })  : _logger = logger,
        _assetPath = assetPath;

  @override
  Future<List<Birthplace>> loadBirthplaces() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map<Birthplace>((json) => Birthplace.fromJson(json))
          .toList();
    } catch (e, s) {
      _logger.e('Failed to load or parse birthplaces asset.', error: e, stackTrace: s);
      return [];
    }
  }
}