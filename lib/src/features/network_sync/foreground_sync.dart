import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pfx_fuhrpark/src/features/network_sync/sync_service.dart';
import '../../../objectbox.g.dart';
import '../../utils/objectbox.dart';
import '../authentication/data/api_url.dart';


void syncData(Map<String, dynamic> args) async {
  SendPort sendPort = args['sendPort'];
  RootIsolateToken rootIsolateToken = args['rootIsolateToken'];
  Api api = args['api'];



  // Reinitialize the binary messenger with the provided token
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);


  debugPrint('Isolate debug name: ${Isolate.current.debugName}');
  debugPrint('Isolate hash: ${Isolate.current.hashCode}');

  final dir = await getApplicationDocumentsDirectory();
  final store = Store.attach(getObjectBoxModel(), "${dir.path}/objectbox");

  final objectBox = ObjectBox.fromStore(store);

  // Create an instance of SyncService and call the sync method
  SyncService syncService = SyncService(api, objectBox);
  // await syncService.syncTest(sendPort: sendPort);
  await syncService.sync(sendPort: sendPort);

  objectBox.store.close();
}


void startForegroundSync(SyncService syncService) {
  Timer.periodic(Duration(minutes: 1 ), (timer) async {
    final receivePort = ReceivePort();
    final rootIsolateToken =
    RootIsolateToken.instance!; // Capture the root isolate token

    Isolate? isolate;

    receivePort.listen((message) {
      debugPrint("FOREGROUND SYNC: $message");

      // Nach erfolgreicher Sync den Isolate killen
      if (message.toString().toLowerCase().contains("erfolgreich") ||
          message.toString().toLowerCase().contains("keine internetverbindung")) {
        isolate?.kill(priority: Isolate.immediate);
        receivePort.close(); // Wichtig: auch Port schließen
      }
    });

    isolate = await Isolate.spawn(
      syncData,
      {
        'sendPort': receivePort.sendPort,
        'rootIsolateToken': rootIsolateToken, // Pass the token to the isolate
        'api': syncService.api,
      },
    );
  });
}