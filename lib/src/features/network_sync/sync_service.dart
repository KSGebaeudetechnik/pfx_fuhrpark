import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import '../../utils/objectbox.dart';
import '../authentication/data/api_url.dart';
import 'network.dart';

class SyncService {
  final ConnectivityChecker connectivityChecker = ConnectivityChecker();
  late final Api api;
  final ObjectBox objectBox;

  SyncService(this.api, this.objectBox);


  // Future<void> syncTest({SendPort? sendPort}) async {
  //   debugPrint(api.url);
  //   final connectivityStatus = await connectivityChecker.checkConnectivity();

  //   if (connectivityStatus != ConnectivityStatus.isConnected) {
  //     final message = 'Keine Internetverbindung';
  //     debugPrint(message);
  //     sendPort?.send(message);
  //     return;
  //   }

  //   debugPrint("Daten werden synchronisiert...");
  //   try {
  //     final response =
  //         await http.post(Uri.parse('${api.url}/sync_test/sync_test.php'));
  //     if (response.statusCode == 200) {
  //       final message = "Daten erfolgreich synchronisiert.";
  //       debugPrint(message);
  //       sendPort?.send(message);
  //     } else {
  //       debugPrint(response.body);
  //       final message =
  //           "Fehler bei der Synchronisation: ${response.statusCode}";
  //       debugPrint(message);
  //       sendPort?.send(message);
  //     }
  //   } on SocketException {
  //     final message =
  //         "Fehler bei der Synchronisation: Keine Internetverbindung.";
  //     debugPrint(message);
  //     sendPort?.send(message);
  //   }
  // }

  Future<void> sync({SendPort? sendPort}) async {
    debugPrint(api.url);
    final connectivityStatus = await connectivityChecker.checkConnectivity();

    if (connectivityStatus != ConnectivityStatus.isConnected) {
      final message = 'Keine Internetverbindung';
      debugPrint(message);
      sendPort?.send(message);
      return;
    }

    debugPrint("Daten werden synchronisiert...");
    try {
      // AuftragRepository auftragRepository = AuftragRepository(objectBox);
      // await auftragRepository.downloadAlleAuftraege();
      // ZeiterfassungRepository zeiterfassungRepository = ZeiterfassungRepository(objectBox);
      // await zeiterfassungRepository.uploadZeiterfassung();
      final message = "Daten erfolgreich synchronisiert.";
      debugPrint(message);
      sendPort?.send(message);
    } on SocketException {
      final message =
          "Fehler bei der Synchronisation: Keine Internetverbindung.";
      debugPrint(message);
      sendPort?.send(message);
    }
  }
}