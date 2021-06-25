#! /usr/bin/env dcli

import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

/// which appname
void main(List<String> args) {
  final parser = ArgParser()..addFlag('verbose', abbr: 'v', negatable: false);

  final results = parser.parse(args);

  final verbose = results['verbose'] as bool?;

  if (results.rest.length != 1) {
    print(red('You must pass the name of the executable to search for.'));
    print(green('Usage:'));
    print(green('   which ${parser.usage}<exe>'));
    exit(1);
  }

  final command = results.rest[0];

  for (final path in PATH) {
    if (verbose!) {
      print('Searching: ${canonicalize(path)}');
    }
    if (exists(join(path, command))) {
      print(red('Found at: ${canonicalize(join(path, command))}'));
    }
  }
}
