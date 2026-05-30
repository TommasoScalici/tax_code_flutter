import 'package:shared/models/contact.dart';

abstract class LocalCacheService {
  Future<List<Contact>> loadContacts(String userId);
  Future<void> saveContacts(String userId, List<Contact> contacts);
  Future<void> clearContacts(String userId);
}
