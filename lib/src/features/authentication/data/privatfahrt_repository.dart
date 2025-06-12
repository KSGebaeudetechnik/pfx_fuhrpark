import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class PrivatfahrtRepository {
  final Uri _url = Uri.parse("https://kstest.pfox.cloud/data/API/fuhrpark/sendPrivatfahrt.php?access=LDFB46HD6sdf4jndJHF689DJj03Jjdsukd");

  Future<bool> updatePrivatfahrt({required int personalnummer, required bool status}) async {
    final body = jsonEncode([
      {"Pnr": personalnummer.toString(), "Status": status ? "1" : "0"}
    ]);

    final client = HttpClient();
    try {
      final request = await client.postUrl(_url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      return responseBody.trim() == "1";
    } catch (e) {
      debugPrint("Fehler beim Senden der Privatfahrt-Statusänderung: $e");
      return false;
    } finally {
      client.close();
    }
  }
}