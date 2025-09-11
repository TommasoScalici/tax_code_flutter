import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Defines the contract for a service that provides app information.
abstract class InfoServiceAbstract {
  Future<PackageInfo> getPackageInfo();
  Future<String> getLocalizedTerms(Locale locale);
}

/// The concrete implementation of [InfoServiceAbstract].
class InfoService implements InfoServiceAbstract {
  final Logger _logger;

  InfoService({required Logger logger}) : _logger = logger;

  @override
  Future<PackageInfo> getPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (e, s) {
      _logger.e('Failed to get package info.', error: e, stackTrace: s);
      // Return a default object on failure to prevent the UI from crashing.
      return PackageInfo(
        appName: 'Error',
        packageName: 'Error',
        version: 'Error',
        buildNumber: 'Error',
      );
    }
  }

  @override
  Future<String> getLocalizedTerms(Locale locale) async {
    final htmlPath = _getLocalizedHtmlTermsPath(locale);
    try {
      return await rootBundle.loadString(htmlPath);
    } catch (e, s) {
      _logger.e(
        'Failed to load terms HTML from $htmlPath',
        error: e,
        stackTrace: s,
      );
      return '<h1>Error</h1><p>Could not load terms and conditions.</p>';
    }
  }

  String _getLocalizedHtmlTermsPath(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return 'assets/html/it/terms.html';
      case 'en':
      default:
        return 'assets/html/en/terms.html';
    }
  }
}
