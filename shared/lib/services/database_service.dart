import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:shared/models/contact.dart';

/// A service class that handles all interactions with FirebaseFirestore.
class DatabaseService {
  final FirebaseFirestore _firestore;

  /// Creates a DatabaseService.
  /// Requires a [FirebaseFirestore] instance.
  DatabaseService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  /// Returns a stream of contacts for a given user.
  /// This stream will emit new lists of contacts whenever data changes on Firestore.
  Stream<List<Contact>> getContactsStream(String userId) {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts');

    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Contact.fromJson(doc.data())).toList();
    });
  }

  /// Saves or updates a single contact in Firestore for a given user.
  Future<void> addOrUpdateContact(String userId, Contact contact) {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contact.id);
    return docRef.set(contact.toJson());
  }

  /// Removes a single contact from Firestore.
  Future<void> removeContact(String userId, String contactId) {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contactId);
    return docRef.delete();
  }

  /// Replaces the entire list of contacts in Firestore with a new list.
  /// This is a batch operation that deletes old contacts and writes the new ones.
  /// Ideal for reordering operations.
  Future<void> saveAllContacts(String userId, List<Contact> contacts) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts');

    final WriteBatch batch = _firestore.batch();

    // 1. Get all existing documents from Firestore
    final remoteSnapshot = await collection.get();

    // 2. Schedule deletions for documents that are no longer in the local list
    final localIds = contacts.map((contact) => contact.id).toSet();
    for (final doc in remoteSnapshot.docs) {
      if (!localIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    // 3. Schedule writes for all current contacts (to add new ones or update existing ones)
    for (final contact in contacts) {
      batch.set(collection.doc(contact.id), contact.toJson());
    }

    // 4. Commit all operations as a single atomic transaction
    await batch.commit();
  }

  /// Saves user metadata to the 'users' collection.
  /// If the user is new, it includes a 'createdAt' timestamp.
  /// Merges data to avoid overwriting existing fields.
  Future<void> saveUserData(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userRef.get();

    final userData = <String, dynamic>{
      'id': user.uid,
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
    };

    if (!userSnapshot.exists) {
      userData['createdAt'] = FieldValue.serverTimestamp();
    }

    await userRef.set(userData, SetOptions(merge: true));
  }
}
