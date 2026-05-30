import 'package:hive_ce/hive.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/services/local_cache_service.dart';

class HiveLocalCacheService implements LocalCacheService {
  String _boxKey(String userId) => 'contacts_$userId';

  @override
  Future<List<Contact>> loadContacts(String userId) async {
    final box = await Hive.openBox<Contact>(_boxKey(userId));
    return box.values.toList();
  }

  @override
  Future<void> saveContacts(String userId, List<Contact> contacts) async {
    final box = await Hive.openBox<Contact>(_boxKey(userId));
    await box.clear();
    await box.putAll({for (var c in contacts) c.id: c});
  }

  @override
  Future<void> clearContacts(String userId) async {
    final box = await Hive.openBox<Contact>(_boxKey(userId));
    await box.clear();
  }
}
