import 'package:firebase_auth/firebase_auth.dart';

/// Lightweight fake implementation of [User] that does not depend on `flutter_test`.
class FakeUser implements User {
  @override
  final String uid;

  @override
  final bool isAnonymous;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final String? photoURL;

  /// Creates a fake user with the provided properties.
  FakeUser({
    this.uid = 'test_uid',
    this.isAnonymous = false,
    this.email,
    this.displayName,
    this.photoURL,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
