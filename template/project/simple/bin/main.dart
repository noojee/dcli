#! /usr/bin/env dart

// ignore: prefer_relative_imports
import 'package:dcli/dcli.dart';

/// dcli script generated by:
/// dcli create %scriptname%
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///
void main(List<String> args) {
  final response =
      ask('say something:', validator: Ask.all([Ask.alpha, Ask.required]));

  print(orange('Your response was: $response'));
}
