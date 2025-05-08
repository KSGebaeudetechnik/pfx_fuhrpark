import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../utils/loading.dart';
import '../../themes/app_themes.dart';
import '../data/auth_repository.dart';



class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  late TextEditingController apiUrlController;
  late TextEditingController usernameController;
  late TextEditingController passwortController;
  // late Uint8List _logoImageData;

  @override
  void initState() {
    apiUrlController = TextEditingController();
    usernameController = TextEditingController();
    passwortController = TextEditingController();
    if(objectBox.apiBox.count() >0) {
      apiUrlController.text = objectBox.apiBox.getAll().first.shortUrl;
    }

    if(!objectBox.loginUserDataBox.isEmpty()) {
      usernameController.text = objectBox.loginUserDataBox.getAll().first.username;
      passwortController.text = objectBox.loginUserDataBox.getAll().first.password;
    }

    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwortController.dispose();
    apiUrlController.dispose();
    super.dispose();
  }

  void submit(String username, String password, String apiURL) async{
    final Future<Map<String,dynamic>> response = ref.read(authProvider.notifier).login(username, password, apiURL, context: context);
    response.then((response) {
      // if (!response['status']) {
      //   Flushbar(
      //     backgroundColor: Theme
      //         // ignore: use_build_context_synchronously
      //         .of(context)
      //         .colorScheme
      //         .error,
      //     title: "Login fehlgeschlagen",
      //     message: response['message'],
      //     duration: Duration(seconds: 3),
      //   // ignore: use_build_context_synchronously
      //   ).show(context);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Easy Set Up for Testing Functions:
//       return MaterialApp(
//         home: Scaffold(
//           appBar: AppBar(title: Text('Permission Example')),
//           body: Center(
//             child: ElevatedButton(
//               onPressed: () async {
//                 CheckPermission checkPermission = CheckPermission();
//                 bool isGranted = await checkPermission.isStoragePermission();
//                 print('Permission granted: $isGranted');
//               },
//               child: Text('Request Permission'),
//             ),
//           ),
//         ),
//       );
//     }
// }
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      body:
      Container(
        color: Theme.of(context).primaryColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage("assets/bilder/background_transparent.png"),
              //     fit: BoxFit.fill,
              //     opacity: 1,
              //   ),
              // ),
              child:
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Positioned(
                    top: 20,
                    child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width/2, // Set the maximum width here
                        ),
                        // child: Image.asset("assets/bilder/powerfox_logo_white.png")
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0, 0.3),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: neutrals700.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Anmelden", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white,),),
                              SizedBox(height: 34,),
                              Text("Firma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),),
                              TextField(
                                // autofillHints: [AutofillHints.username],
                                controller: apiUrlController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  hintStyle: TextStyle(fontSize: 16, color: neutrals700),
                                  hintText: "musterfirma.pfox.cloud",
                                  filled: true,
                                  fillColor: neutrals300,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:  neutrals900,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24,),
                              AutofillGroup(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Benutzername", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),),
                                    TextField(
                                      autofillHints: [AutofillHints.username],
                                      controller: usernameController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        hintStyle: TextStyle(fontSize: 16, color: neutrals500),
                                        hintText: "M.Mustermann",
                                        filled: true,
                                        fillColor: neutrals300,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:  neutrals900,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24,),
                                    Text("Passwort", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),),
                                    TextField(
                                      autofillHints: [AutofillHints.password],
                                      obscureText: true,
                                      controller: passwortController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        hintStyle: TextStyle(fontSize: 16, color: neutrals500),
                                        hintText: "Passwort",
                                        filled: true,
                                        fillColor: neutrals300,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:  neutrals900,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 32,),
                                    Row(
                                      children: [
                                        ref.watch(authProvider) == AuthStatus.authenticating ? Loading() : Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed: () {
                                              TextInput.finishAutofillContext();
                                              debugPrint(usernameController.text);
                                              submit(usernameController.text, passwortController.text, apiUrlController.text);
                                            },
                                            child: Text("Anmelden"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
