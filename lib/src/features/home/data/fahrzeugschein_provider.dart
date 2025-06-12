import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../utils/access_code.dart';

final fahrzeugscheinProvider = FutureProvider.family<({Uint8List? data, String? contentType}), String>((ref, kennzeichen) async {
  final url = Uri.parse(
      'https://kstest.pfox.cloud/data/API/fuhrpark/getSchein.php?access=$access&kennzeichen=$kennzeichen');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    return (data: response.bodyBytes, contentType: response.headers['content-type']);
  } else {
    throw Exception('Fehler beim Laden des Fahrzeugscheins');
  }
});