import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

/// Service that observes and captures deep link URIs dispatched to the application
/// (both cold start and runtime/warm start intents).
class DeepLinkService with WidgetsBindingObserver, ChangeNotifier {
  final Logger? _logger;
  Uri? _pendingDeepLink;

  DeepLinkService({Logger? logger, String? initialRoute}) : _logger = logger {
    WidgetsBinding.instance.addObserver(this);
    _checkInitialRoute(initialRoute);
  }

  /// The currently pending deep link URI, if any.
  Uri? get pendingDeepLink => _pendingDeepLink;

  void _checkInitialRoute(String? initialRoute) {
    final route = initialRoute ?? PlatformDispatcher.instance.defaultRouteName;
    if (route.isNotEmpty && route != '/') {
      final uri = Uri.tryParse(route);
      if (uri != null && _isSupportedScheme(uri)) {
        _pendingDeepLink = uri;
        _logger?.i('Captured initial deep link: $uri');
      }
    }
  }

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    if (_isSupportedScheme(uri)) {
      _logger?.i('Received runtime deep link: $uri');
      _pendingDeepLink = uri;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Returns the current pending deep link (if any) and clears it.
  Uri? consumePendingDeepLink() {
    final uri = _pendingDeepLink;
    _pendingDeepLink = null;
    return uri;
  }

  /// Manually sets a pending deep link (primarily for testing or internal triggers).
  void setPendingDeepLink(Uri uri) {
    if (_isSupportedScheme(uri)) {
      _pendingDeepLink = uri;
      notifyListeners();
    }
  }

  /// Clears any pending deep link without consuming it.
  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  bool _isSupportedScheme(Uri uri) {
    return uri.scheme == 'taxcode' || uri.scheme == 'app';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
