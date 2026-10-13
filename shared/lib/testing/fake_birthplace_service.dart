import 'package:flutter/foundation.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/testing/test_contact_fixtures.dart';

/// Fake implementation of [BirthplaceService] for testing and previews.
class FakeBirthplaceService implements BirthplaceService {
  final List<Birthplace> _birthplaces;
  bool _isDisposed = false;

  @override
  final ValueNotifier<double?> downloadProgress = ValueNotifier<double?>(null);

  @override
  final ValueNotifier<String?> downloadStep = ValueNotifier<String?>(null);

  FakeBirthplaceService([List<Birthplace>? birthplaces])
    : _birthplaces = birthplaces ?? TestContactFixtures.sampleBirthplaces;

  @override
  Future<List<Birthplace>> loadBirthplaces() async => _birthplaces;

  @override
  void dispose() {
    _isDisposed = true;
    downloadProgress.dispose();
    downloadStep.dispose();
  }

  @override
  Future<void>? get backgroundUpdateFuture => null;

  @override
  bool get isDisposed => _isDisposed;
}
