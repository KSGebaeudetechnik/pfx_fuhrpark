import 'package:flutter/material.dart';

/// Widget zum anzeigen des "Loading"-Status
class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        CircularProgressIndicator(),
        Text(" Lädt ... Bitte warten")
      ],
    );
  }
}