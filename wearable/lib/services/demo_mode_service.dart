import 'package:flutter/foundation.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';

/// Contract defining the demo mode operations and state for Wear OS.
abstract interface class DemoModeServiceAbstract extends ChangeNotifier {
  /// Whether demo mode is currently active.
  bool get isDemoMode;

  /// Returns the unmodifiable list of pre-populated demo contacts.
  List<Contact> get demoContacts;

  /// Activates demo mode and notifies listeners.
  void enableDemoMode();

  /// Deactivates demo mode and notifies listeners.
  void exitDemoMode();
}

/// Service managing the ephemeral demo mode state on Wear OS.
///
/// Designed to allow Google Play Store reviewers to evaluate the watch UI
/// and barcode/QR display functionality without needing a Google test account.
class DemoModeService extends ChangeNotifier implements DemoModeServiceAbstract {
  bool _isDemoMode = false;

  @override
  bool get isDemoMode => _isDemoMode;

  static final List<Contact> _sampleContacts = List.unmodifiable([
    Contact(
      id: 'demo-mario-rossi',
      firstName: 'Mario',
      lastName: 'Rossi',
      gender: 'M',
      taxCode: 'RSSMRA80A01H501U',
      birthPlace: const Birthplace(name: 'Roma', state: 'RM', code: 'H501'),
      birthDate: DateTime(1980),
      listIndex: 0,
    ),
    Contact(
      id: 'demo-laura-bianchi',
      firstName: 'Laura',
      lastName: 'Bianchi',
      gender: 'F',
      taxCode: 'BNCLRA85M41F205Z',
      birthPlace: const Birthplace(name: 'Milano', state: 'MI', code: 'F205'),
      birthDate: DateTime(1985, 8),
      listIndex: 1,
    ),
    Contact(
      id: 'demo-giuseppe-verdi',
      firstName: 'Giuseppe',
      lastName: 'Verdi',
      gender: 'M',
      taxCode: 'VRDGPP75E15L219S',
      birthPlace: const Birthplace(name: 'Torino', state: 'TO', code: 'L219'),
      birthDate: DateTime(1975, 5, 15),
      listIndex: 2,
    ),
  ]);

  @override
  List<Contact> get demoContacts => _sampleContacts;

  @override
  void enableDemoMode() {
    if (_isDemoMode) return;
    _isDemoMode = true;
    notifyListeners();
  }

  @override
  void exitDemoMode() {
    if (!_isDemoMode) return;
    _isDemoMode = false;
    notifyListeners();
  }
}
