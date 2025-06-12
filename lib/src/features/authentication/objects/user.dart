import 'package:objectbox/objectbox.dart';

@Entity()
class User {

  @Id()
  int id;

  late int personalnummer;
  late String mail;
  late String name;
  late int adminRecht;
  late bool privatfahrt;
  late bool prozentregelung;



  User({
    this.id = 0,
    required this.personalnummer,
    required this.mail,
    required this.name,
    required this.adminRecht,
    required this.privatfahrt,
    required this.prozentregelung,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    personalnummer: int.parse(json['Pnr']),
    mail: json["Mail"],
    name: json["Username"],
    adminRecht: int.parse(json['Alle']),
    privatfahrt: json['Privatfahrt'] == "1",
    prozentregelung: json['Prozentregelung'] == "1",
  );

  Map<String, dynamic> toJson() => {
    "Pnr": personalnummer,
    "Username": name,
    "Privatfahrt": privatfahrt ? "1" : "0",
    "Prozentregelung": prozentregelung ? "1" : "0",
  };

}