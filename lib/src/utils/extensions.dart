import 'package:flutter/material.dart';

// um colorTheme und textTheme in allen Klassen & Widgets als Variablen nutzen zu können
// Zugriff mit context.textTheme oder context.colorTheme
// Import der Extension wie bei home_screen

extension ThemeVariable on BuildContext{
  TextTheme get textTheme{
    return Theme.of(this).textTheme;
  }
  ColorScheme get colorTheme{
    return Theme.of(this).colorScheme;
  }
}