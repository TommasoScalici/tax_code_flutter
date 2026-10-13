import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/testing/test_contact_fixtures.dart';
import 'package:tax_code_flutter/controllers/home_page_controller.dart';
import 'package:tax_code_flutter/services/brightness_service.dart';
import 'package:tax_code_flutter/services/in_app_review_service.dart';
import 'package:tax_code_flutter/services/info_service.dart';
import 'package:tax_code_flutter/services/sharing_service.dart';

/// Centralized fake implementation of [SharingService] for previews and widget tests.
class FakeSharingService implements SharingService {
  const FakeSharingService();

  @override
  Future<ShareResult> share({required String text}) async =>
      const ShareResult('', ShareResultStatus.success);

  @override
  Future<ShareResult> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  }) async => const ShareResult('', ShareResultStatus.success);
}

/// Centralized fake implementation of [BrightnessService] for previews.
class FakeBrightnessService implements BrightnessService {
  bool isMaxBrightness = false;

  @override
  Future<void> setMaxBrightness() async {
    isMaxBrightness = true;
  }

  @override
  Future<void> resetBrightness() async {
    isMaxBrightness = false;
  }
}

/// Centralized fake implementation of [InfoService] for previews.
class FakeInfoService implements InfoService {
  final PackageInfo _packageInfo;

  /// Creates a [FakeInfoService] with optional custom [packageInfo].
  FakeInfoService([PackageInfo? packageInfo])
    : _packageInfo =
          packageInfo ??
          PackageInfo(
            appName: 'Codice Fiscale',
            packageName: 'tommasoscalici.taxcode',
            version: '2.0.0',
            buildNumber: '1',
            installerStore: 'Google Play',
          );

  @override
  Future<PackageInfo> getPackageInfo() async => _packageInfo;
}

/// Centralized fake implementation of [InAppReviewService] for previews.
class FakeInAppReviewService implements InAppReviewService {
  @override
  Future<void> openStoreListing() async {}

  @override
  Future<void> maybeRequestReview() async {}
}

/// Centralized fake implementation of [HomePageController] for previews.
class FakeHomePageController extends ChangeNotifier
    implements HomePageController {
  final List<Contact> _contacts;
  String _searchText = '';
  bool _isLoading = false;

  /// Creates a [FakeHomePageController] initialized with contacts.
  FakeHomePageController([List<Contact>? initialContacts])
    : _contacts = List<Contact>.from(
        initialContacts ?? TestContactFixtures.sampleContacts,
      );

  @override
  List<Contact> get contactsToShow => _searchText.isEmpty
      ? _contacts
      : _contacts
            .where(
              (c) =>
                  c.firstName.toLowerCase().contains(_searchText) ||
                  c.lastName.toLowerCase().contains(_searchText) ||
                  c.taxCode.toLowerCase().contains(_searchText),
            )
            .toList();

  /// Returns all stored contacts.
  List<Contact> get contacts => List.unmodifiable(_contacts);

  @override
  bool get hasContacts => _contacts.isNotEmpty;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isReorderable => _searchText.isEmpty;

  @override
  String get searchText => _searchText;

  @override
  void filterContacts(String text) {
    _searchText = text.toLowerCase();
    notifyListeners();
  }

  @override
  void reorderContacts(int oldIndex, int newIndex) {
    final item = _contacts.removeAt(oldIndex);
    _contacts.insert(newIndex, item);
    notifyListeners();
  }

  @override
  void shareContact(Contact contact) {}

  @override
  Future<void> saveContact(Contact contact) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    notifyListeners();
  }

  @override
  Future<void> deleteContact(Contact contact) async {
    _contacts.removeWhere((c) => c.id == contact.id);
    notifyListeners();
  }

  /// Sets loading state.
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Replaces the current contacts list.
  void setContacts(List<Contact> contacts) {
    _contacts.clear();
    _contacts.addAll(contacts);
    notifyListeners();
  }
}
