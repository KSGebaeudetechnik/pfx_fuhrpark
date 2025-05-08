import 'dart:io';

import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import '../features/authentication/data/api_url.dart';
import '../features/authentication/data/login_user_data.dart';
import '../features/authentication/objects/user.dart';
import '../features/home/objects/fahrzeug.dart';

class ObjectBox {
  static Store? _store;

  late final Store store;
  late final Box<User> userBox;
  late final Box<Api> apiBox;
  late final Box<LoginUserData> loginUserDataBox;
  late final Box<Fahrzeug> fahrzeugBox;

  Admin? admin;

  ObjectBox._create(this.store) {
    _store = store;

    if (Admin.isAvailable()) {
      admin = Admin(store);
    }

    userBox = Box<User>(store);
    apiBox = Box<Api>(store);
    loginUserDataBox = Box<LoginUserData>(store);
    fahrzeugBox = Box<Fahrzeug>(store);

  }

  /// Main factory method
  static Future<ObjectBox> create() async {
    if (_store != null && !_store!.isClosed()) {
      return ObjectBox._create(_store!); // Reuse the existing store
    }

    Store? store;

    try {
      store = await openStore();
    } catch (e) {
      if (e is ObjectBoxException || e.toString().contains("another store is still open")) {
        try {
          _store?.close();
        } catch (_) {}

        final dir = await _getObjectBoxDirectory();
        await Directory(dir).delete(recursive: true);

        store = await openStore();
      } else {
        rethrow;
      }
    }

    return ObjectBox._create(store);
  }

  // ✅ Public factory to use attached store in isolates
  static ObjectBox fromStore(Store store) {
    return ObjectBox._create(store);
  }

  // Add this for isolate use
  static Future<ObjectBox> createIsolated() async {
    final store = await openStore(); // Safe in a new isolate
    return ObjectBox._create(store);
  }

  static Future<String> _getObjectBoxDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return join(appDocDir.path, "objectbox");
  }

  /// Cleanly close the store (e.g. in background isolate or shutdown)
  static void close() {
    _store?.close();
    _store = null;
  }
}

Future<void> wipeObjectbox(ObjectBox objectBox, {required bool withUser}) async {
  if (withUser) {
    objectBox.userBox.removeAll();
    objectBox.fahrzeugBox.removeAll();
  }

  objectBox.loginUserDataBox.removeAll();

}

