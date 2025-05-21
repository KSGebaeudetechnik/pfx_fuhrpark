import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/access_code.dart';
import '../objects/fahrt.dart';

class FahrtenbuchRepository {
  final String baseUrl = "https://kstest.pfox.cloud/data/API/fuhrpark/getFahrtenbuch.php";

  Future<List<Fahrt>> fetchFahrtenbuch(String userId, DateTime date) async {
    final url = Uri.parse("$baseUrl?access=$access&user=$userId&date=${date.toIso8601String().split('T').first}");
    // print(url);
    final response = await http.get(url);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Fahrt.fromJson(e)).toList();
    } else {
      throw Exception("Fahrtenbuch konnte nicht geladen werden");
    }
  }
}