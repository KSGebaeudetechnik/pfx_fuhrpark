import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/access_code.dart';
import '../../../utils/objectbox.dart'; // Deine zentrale ObjectBox-Instanz
import '../objects/fahrzeug.dart';

class FahrzeugRepository {
  final ObjectBox objectBox;

  // API-Konfiguration
  final String apiUrl = "https://kstest.pfox.cloud/data/API/fuhrpark/getFahrzeuge.php";

  FahrzeugRepository(this.objectBox);

  /// Holt Fahrzeugdaten von der API und speichert gültige in ObjectBox
  Future<List<Fahrzeug>> fetchAndStoreFahrzeuge(String userId) async {
    final url = Uri.parse("$apiUrl?access=$access&user=$userId");

    final response = await http.get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> jsonList = json.decode(response.body);

      final fahrzeuge = jsonList.map((e) => Fahrzeug.fromJson(e)).toList();

      // Nur Fahrzeuge mit gültigem OBJECTNAME speichern
      final gueltigeFahrzeuge = fahrzeuge
        .where((f) => f.objektName != null && f.objektName!.trim().isNotEmpty)
        .toList();

    objectBox.fahrzeugBox.removeAll();
    objectBox.fahrzeugBox.putMany(gueltigeFahrzeuge);

    return gueltigeFahrzeuge;
    } else {
    throw Exception("Fahrzeuge konnten nicht geladen werden (Status: ${response.statusCode})");
    }
  }

  /// Gibt alle lokal gespeicherten Fahrzeuge zurück
  List<Fahrzeug> getLocalFahrzeuge() {
    return objectBox.fahrzeugBox.getAll();
  }
}