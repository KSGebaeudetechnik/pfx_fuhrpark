import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../main.dart';
// import '../../../navigation/nav_bar.dart';
import '../../../utils/access_code.dart';
import '../../../utils/objectbox.dart';
import '../../network_sync/background_sync.dart';
import '../../network_sync/foreground_sync.dart';
import '../../network_sync/sync_service.dart';
import '../objects/user.dart';
import 'api_url.dart';
import 'login_user_data.dart';

enum AuthStatus {
  signedOut,
  signedIn,
  authenticating,
  loading,
}

class AuthRepository extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() async {
    // Check if a user exists in ObjectBox
    return objectBox.userBox.count() > 0 ? AuthStatus.signedIn : AuthStatus.signedOut;
  }

  Future<Map<String, dynamic>> login(String username, String password, String url, {
    required BuildContext context,
  }) async {
    state = const AsyncValue.data(AuthStatus.authenticating);

    /// Convert password to SHA-256
    final bytes = utf8.encode(password);
    final passwordHashed = sha256.convert(bytes).toString();

    final loginData = {
      'access': access,
      'name': username,
      'passwort': passwordHashed,
    };

    try {
      Api api;
      if (objectBox.apiBox.isEmpty()) {
        api = Api();
      } else {
        api = objectBox.apiBox.getAll().first;
      }
      api.apiUrl = url;
      api.shortUrl = url;
      objectBox.apiBox.put(api);

      debugPrint("LOGIN !!!!!!!!!!!!!!!!!!!!!!!");
      debugPrint(api.apiUrl);
      debugPrint(objectBox.apiBox.getAll().first.apiUrl);

      //https://kstest.pfox.cloud/data/API/fuhrpark/login.php?access=LDFB46HD6sdf4jndJHF689DJj03Jjdsukd&benutzer=webmaster&pw=399e69bede693af17499ce175b971329c424f5eac275e83b66005e7162dddc1b

      debugPrint("${api.url}/login.php?access=LDFB46HD6sdf4jndJHF689DJj03Jjdsukd&benutzer=$username&pw=$passwordHashed");

      final response = await http.get(
        Uri.parse("${api.url}/login.php?access=LDFB46HD6sdf4jndJHF689DJj03Jjdsukd&benutzer=$username&pw=$passwordHashed"),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final loginUserData = LoginUserData(username: username, password: password);
        objectBox.loginUserDataBox.put(loginUserData);

        print(responseData);

        final user = User.fromJson(responseData[0]);
        objectBox.userBox.put(user);

        // final mitarbeiterRepository = MitarbeiterRepository();
        // await mitarbeiterRepository.downloadMitarbeiter();

        // final firma = Firma.fromJson(responseData);
        // objectBox.firmenBox.put(firma);
        // syncService = SyncService(objectBox.apiBox.getAll().first, objectBox);
        //
        // debugPrint("Foreground Sync started.");
        // startForegroundSync(syncService);
        //
        // debugPrint("Background Sync started.");
        // initBackgroundFetch(syncService);

        state = AsyncValue.data(AuthStatus.signedIn);
        context.go('/home'); // oder goNamed(AppRoute.home.name)
        // myAppKey.currentState?.reload();
        // navBarKey.currentState?.reload();
        // navigationshell.goBranch(1);

        return {'status': true, 'message': 'Successful'};
      } else {
        print("Nutzername falsch");
        state = AsyncValue.data(AuthStatus.signedOut);
        return {'status': false, 'message': 'Bitte Username und Passwort überprüfen!'};
      }
    } on SocketException {
      state = AsyncValue.data(AuthStatus.signedOut);
      return {'status': false, 'message': 'Keine Internetverbindung.'};
    } catch (e, s) {
      debugPrint("Error: $e");
      debugPrint("StackTrace: $s");
      state = AsyncValue.data(AuthStatus.signedOut);
      return {'status': false, 'message': 'Falsche URL, bitte überprüfen.'};
    }
  }

  Future<void> logout() async {
    await wipeObjectbox(objectBox, withUser: true);
    state = AsyncValue.data(AuthStatus.signedOut);
  }


}

final authProvider = AsyncNotifierProvider<AuthRepository, AuthStatus>(() => AuthRepository());

final userProvider = FutureProvider<User>((ref) async {
  final userList = objectBox.userBox.getAll();
  return userList.isNotEmpty ? userList.first : throw Exception("No user found");
});