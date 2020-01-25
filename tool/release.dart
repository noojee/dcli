#! /usr/bin/env dshell
import 'dart:io';

import 'package:dshell/dshell.dart';
import 'package:dshell/src/pubspec/pubspec_file.dart';
import 'package:pub_semver/pub_semver.dart';

void main(List<String> args) {
  var cwd = pwd;
  var pubspecName = 'pubspec.yaml';
  var pubspecPath = join(cwd, pubspecName);
  var found = true;


  var parser = ArgParser();


  parser.addFlag('incVersion',
      abbr: 'i',
      defaultsTo: true,
      help: 'Prompts the to increment the version no.');

  parser.addCommand('help');
  var results = parser.parse(args);

  // only one commmand so it must be help
  if (results.command != null) {
    showUsage(parser);
    exit(0);
  }

  // showEditor('/tmp/test.path');

  var incVersion = results['incVersion'] as bool;

  // climb the path searching for the pubspec
  while (!exists(pubspecPath)) {
    cwd = dirname(cwd);
    if (cwd == '/') {
      found = false;
      break;
    }
    pubspecPath = join(cwd, pubspecName);
  }

  if (!found) {
    print(
        'Unable to find pubspec.yaml, run release from the dshell root directory.');
  }
  var pubspec = PubSpecFile.fromFile(pubspecPath);

  // check that the pubspec is ours
  if (pubspec.name != 'dshell') {
    print(
        'Found a pubspec at ${absolute(pubspecPath)} but it does not belong to dshell. ');
    exit(-1);
  }

  var version = pubspec.version;

  print('Found pubspec.yaml in ${absolute(pubspecPath)}');
  print('Current Dshell version is $version');

  if (incVersion) {
    version = incrementVersion(version, pubspec, pubspecPath);
  }

  if (confirm(prompt: 'Create a git release tag (Y/N):')) {
    var tagName = 'v${version}';

    // Check if the tag already exists and offer to replace it if it does.
    if (tagExists(tagName)) {
      var replace = ask(
          prompt:
              'The tag $tagName already exists. Do you want to replace it?');
      if (replace.toLowerCase() == 'y') {
        'git tag -d $tagName'.run;
        'git push origin :refs/tags/$tagName'.run;
        print('');
      }
    }

    'git tag -a $tagName'.run;

    var message = ask(prompt: 'Enter a release message:');
    'git tag -a $tagName -m "$message"'.run;
  }
}

void showUsage(ArgParser parser) {
  print('''Releases a dart project:
      Increments the version no. in pubspec.yaml
      Regenerates src/util/version.g.dart with the new version no.
      Creates a git tag with the version no. in the form 'v<version-no>'
      Updates the CHANGELOG.md with a new version no. and the set of
      git commit messages.
      Commits the above changes
      Pushes the final results to git
      Runs docker unit tests checking that they have passed (?how)
      Publishes the package using 'pub publish'

      Usage:
      ${parser.usage}
      ''');
}

bool tagExists(String tagName) {
  var tags = 'git tag --list'.toList();

  return (tags.contains(tagName));
}

Version incrementVersion(
    Version version, PubSpecFile pubspec, String pubspecPath) {
  if (confirm(prompt: 'Is this a breaking change? (Y/N)')) {
    version = version.nextBreaking;
  } else if (confirm(prompt: 'Is a small patch? (Y/N)')) {
    version = version.nextPatch;
  } else {
    version = version.nextMinor;
  }

  // recreate the version file
  var dshellRootPath = dirname(pubspecPath);

  print('');
  print('The new version is: $version');
  if (confirm(prompt: 'Is this the correct version (Y/N): ')) {
    // write new version.g.dart file.
    var versionPath =
        join(dshellRootPath, 'lib', 'src', 'util', 'version.g.dart');
    print('Regenerating version file at ${absolute(versionPath)}');
    versionPath
        .write('/// GENERATED BY dshell tool/release.dart do not modify.');
    versionPath.append('');
    versionPath.append("var dshell_version = '$version';");

    // rewrite the pubspec.yaml with the new version
    pubspec.version = version;
    pubspec.writeToFile(pubspecPath);
  }
  return version;
}
