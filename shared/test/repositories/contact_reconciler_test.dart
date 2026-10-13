import 'package:flutter_test/flutter_test.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_reconciler.dart';

void main() {
  const birthplace = Birthplace(name: 'Roma', state: 'RM', code: 'H501');

  Contact createTestContact({
    required String id,
    required String firstName,
    required String taxCode,
    required int listIndex,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id,
      firstName: firstName,
      lastName: 'Rossi',
      gender: 'M',
      taxCode: taxCode,
      birthDate: DateTime(1990),
      birthPlace: birthplace,
      listIndex: listIndex,
      updatedAt: updatedAt,
    );
  }

  group('ContactReconciler.reconcileByTimestamp', () {
    test('returns empty list when both remote and local are empty', () {
      final result = ContactReconciler.reconcileByTimestamp(
        remoteContacts: [],
        localContacts: [],
      );
      expect(result, isEmpty);
    });

    test('retains remote contacts when local contacts are empty', () {
      final remote = [
        createTestContact(
          id: '1',
          firstName: 'Mario',
          taxCode: 'RSSMRA90A01H501Z',
          listIndex: 5,
        ),
      ];

      final result = ContactReconciler.reconcileByTimestamp(
        remoteContacts: remote,
        localContacts: [],
      );

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.listIndex, 0); // Re-indexed to 0
    });

    test('retains local contacts when remote contacts are empty', () {
      final local = [
        createTestContact(
          id: '1',
          firstName: 'Mario',
          taxCode: 'RSSMRA90A01H501Z',
          listIndex: 3,
        ),
      ];

      final result = ContactReconciler.reconcileByTimestamp(
        remoteContacts: [],
        localContacts: local,
      );

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.listIndex, 0);
    });

    test(
      'prefers local contact if local.updatedAt is strictly after remote.updatedAt',
      () {
        final t1 = DateTime(2026, 1, 1, 10);
        final t2 = DateTime(2026, 1, 1, 12);

        final remote = [
          createTestContact(
            id: '1',
            firstName: 'Mario Remote',
            taxCode: 'RSSMRA90A01H501Z',
            listIndex: 0,
            updatedAt: t1,
          ),
        ];
        final local = [
          createTestContact(
            id: '1',
            firstName: 'Mario Local',
            taxCode: 'RSSMRA90A01H501Z',
            listIndex: 0,
            updatedAt: t2,
          ),
        ];

        final result = ContactReconciler.reconcileByTimestamp(
          remoteContacts: remote,
          localContacts: local,
        );

        expect(result.length, 1);
        expect(result.first.firstName, 'Mario Local');
      },
    );

    test('prefers remote contact if remote.updatedAt is newer or equal', () {
      final t1 = DateTime(2026, 1, 1, 10);
      final t2 = DateTime(2026, 1, 1, 12);

      final remote = [
        createTestContact(
          id: '1',
          firstName: 'Mario Remote',
          taxCode: 'RSSMRA90A01H501Z',
          listIndex: 0,
          updatedAt: t2,
        ),
      ];
      final local = [
        createTestContact(
          id: '1',
          firstName: 'Mario Local',
          taxCode: 'RSSMRA90A01H501Z',
          listIndex: 0,
          updatedAt: t1,
        ),
      ];

      final result = ContactReconciler.reconcileByTimestamp(
        remoteContacts: remote,
        localContacts: local,
      );

      expect(result.length, 1);
      expect(result.first.firstName, 'Mario Remote');
    });

    test('prefers local contact when only local has updatedAt', () {
      final remote = [
        createTestContact(
          id: '1',
          firstName: 'Mario Remote',
          taxCode: 'RSSMRA90A01H501Z',
          listIndex: 0,
        ),
      ];
      final local = [
        createTestContact(
          id: '1',
          firstName: 'Mario Local',
          taxCode: 'RSSMRA90A01H501Z',
          listIndex: 0,
          updatedAt: DateTime(2026),
        ),
      ];

      final result = ContactReconciler.reconcileByTimestamp(
        remoteContacts: remote,
        localContacts: local,
      );

      expect(result.length, 1);
      expect(result.first.firstName, 'Mario Local');
    });

    test('sorts final list by listIndex and re-indexes sequentially 0..n', () {
      final remote = [
        createTestContact(
          id: 'rem1',
          firstName: 'Remote One',
          taxCode: 'REM1',
          listIndex: 10,
        ),
      ];
      final local = [
        createTestContact(
          id: 'loc1',
          firstName: 'Local One',
          taxCode: 'LOC1',
          listIndex: 2,
        ),
      ];

      final result = ContactReconciler.reconcileByTimestamp(
        remoteContacts: remote,
        localContacts: local,
      );

      expect(result.length, 2);
      expect(result[0].id, 'loc1');
      expect(result[0].listIndex, 0);
      expect(result[1].id, 'rem1');
      expect(result[1].listIndex, 1);
    });
  });

  group('ContactReconciler.mergeGuestIntoRemote', () {
    test('preserves remote contacts and adds unique guest contacts', () {
      final remote = [
        createTestContact(
          id: 'rem1',
          firstName: 'Remote User',
          taxCode: 'REMOTE111',
          listIndex: 0,
        ),
      ];
      final guest = [
        createTestContact(
          id: 'guest1',
          firstName: 'Guest User',
          taxCode: 'GUEST222',
          listIndex: 0,
        ),
      ];

      final result = ContactReconciler.mergeGuestIntoRemote(
        remoteContacts: remote,
        guestContacts: guest,
      );

      expect(result.length, 2);
      expect(result[0].id, 'rem1');
      expect(result[0].listIndex, 0);
      expect(result[1].id, 'guest1');
      expect(result[1].listIndex, 1);
    });

    test(
      'ignores guest contact if taxCode already exists in remote (case-insensitive)',
      () {
        final remote = [
          createTestContact(
            id: 'rem1',
            firstName: 'Remote User',
            taxCode: 'DUP123',
            listIndex: 0,
          ),
        ];
        final guest = [
          createTestContact(
            id: 'guest1',
            firstName: 'Guest Duplicate',
            taxCode: 'dup123',
            listIndex: 1,
          ),
        ];

        final result = ContactReconciler.mergeGuestIntoRemote(
          remoteContacts: remote,
          guestContacts: guest,
        );

        expect(result.length, 1);
        expect(result.first.id, 'rem1');
      },
    );

    test('ignores guest contact if id already exists in remote', () {
      final remote = [
        createTestContact(
          id: 'shared_id',
          firstName: 'Remote User',
          taxCode: 'REM1',
          listIndex: 0,
        ),
      ];
      final guest = [
        createTestContact(
          id: 'shared_id',
          firstName: 'Guest With Same ID',
          taxCode: 'GUEST1',
          listIndex: 1,
        ),
      ];

      final result = ContactReconciler.mergeGuestIntoRemote(
        remoteContacts: remote,
        guestContacts: guest,
      );

      expect(result.length, 1);
      expect(result.first.id, 'shared_id');
      expect(result.first.taxCode, 'REM1');
    });
  });
}
