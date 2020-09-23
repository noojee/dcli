#! /usr/bin/env %dcliName%

import 'dart:io';
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
  var parser = ArgParser();
  parser.addFlag(
    'verbose',
    abbr: 'v',
    negatable: false,
    defaultsTo: false,
    help: 'Logs additional details to the cli',
  );

  parser.addOption('prompt', abbr: 'p', help: 'The prompt to show the user.');

  var parsed = parser.parse(args);

  if (parsed.wasParsed('verbose')) {
    Settings().setVerbose(enabled: true);
  }

  if (!parsed.wasParsed('prompt')) {
    printerr(red('You must pass a prompt'));
    showUsage(parser);
  }

  var prompt = parsed['prompt'] as String;

  var valid = false;
  String response;
  do {
    response = ask('$prompt:', validator: Ask.all([Ask.alpha, Ask.required]));

    valid = confirm('Is this your response? ${green(response)}');
  } while (!valid);

  print(orange('Your response was: $response'));
}

void showUsage(ArgParser parser) {
  print('Usage: %scriptname% -v -prompt <a questions>');
  print(parser.usage);
  exit(1);
}
