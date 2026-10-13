import 'package:flutter/foundation.dart';
import 'package:shared/services/sync_service.dart';

/// Centralized fake implementation of [SyncService] for tests and previews.
class FakeSyncService extends ChangeNotifier implements SyncService {
  bool _enabled;
  bool _canSync;

  /// Creates a [FakeSyncService] with customizable sync availability.
  FakeSyncService({bool enabled = true, bool canSync = true})
      : _enabled = enabled,
        _canSync = canSync;

  @override
  bool get isSyncEnabled => _canSync && _enabled;

  @override
  bool get isUserSyncEnabled => _enabled;

  @override
  bool get canSync => _canSync;

  @override
  Future<void> init() async {}

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    _enabled = enabled;
    notifyListeners();
  }

  @override
  Future<void> toggleSync() async {
    _enabled = !_enabled;
    notifyListeners();
  }

  /// Controls whether cloud sync is available for the current account.
  void setCanSync(bool canSync) {
    _canSync = canSync;
    notifyListeners();
  }
}
