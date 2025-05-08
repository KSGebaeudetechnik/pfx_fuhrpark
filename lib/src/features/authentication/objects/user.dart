import 'package:objectbox/objectbox.dart';

@Entity()
class User {

  @Id()
  int id;

  late int personalnummer;
  late String mail;
  late String name;
  late int adminRecht;



  User({
    this.id = 0,
    required this.personalnummer,
    required this.mail,
    required this.name,
    required this.adminRecht
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    personalnummer: int.parse(json['Pnr']),
    mail: json["Mail"],
    name: json["Username"],
    adminRecht: int.parse(json['Alle']),
  );

  Map<String, dynamic> toJson() => {
    "Pnr": personalnummer,
    "Username": name,
  };

}