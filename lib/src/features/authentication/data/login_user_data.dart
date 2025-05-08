import 'package:objectbox/objectbox.dart';

@Entity()
class LoginUserData {

  @Id()
  int id;

  late String username;
  late String password;

  LoginUserData({
    this.id = 0,
    required this.username,
    required this.password,
  });


}