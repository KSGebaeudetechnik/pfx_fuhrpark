class Fahrt {
  final DateTime startzeit;
  final DateTime stopzeit;
  final double strecke;
  final String? startOrt;
  final String? zielOrt;

  Fahrt({
    required this.startzeit,
    required this.stopzeit,
    required this.strecke,
    this.startOrt,
    this.zielOrt,
  });

  factory Fahrt.fromJson(Map<String, dynamic> json) {
    return Fahrt(
      startzeit: DateTime.parse(json['Startzeit']),
      stopzeit: DateTime.parse(json['StopZeit']),
      strecke: double.tryParse(json['Strecke'].toString()) ?? 0.0,
      startOrt: json['StartAdresse'],
      zielOrt: json['StopAdresse'],
    );
  }
}