import 'package:flutter/foundation.dart';

///
/// Manages the global UI state of the application, such as search mode.
/// This class holds transient state that affects multiple widgets simultaneously.
///
class AppState with ChangeNotifier {
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  ///
  /// Sets the application's search mode.
  /// Notifies listeners to rebuild UI elements that depend on this state.
  ///
  void setSearchState(bool isSearching) {
    if (_isSearching == isSearching) {
      return;
    }
    _isSearching = isSearching;
    notifyListeners();
  }
}
