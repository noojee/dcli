import 'dart:io';

import 'package:dshell/commands/command.dart';
import 'package:file_utils/file_utils.dart' as util;

import '../dshell.dart';
import 'settings.dart';

import '../util/log.dart';

///
/// Returns the list of files in the current
/// directory that match the passed glob pattern.
///
/// Valid glob patterns are:
///
/// [*] - matches any number of any characters including none
///
/// [?] -  matches any single character
///
/// [\[abc\]] - matches any one character given in the bracket
///
/// [\[a-z\] - matches one character from the (locale-dependent) range given in the bracket
///
/// [\[!abc\]] - matches one character that is not given in the bracket
///
/// [\[!a-z\]] - matches one character that is not from the range given in the bracket
///
/// If [caseSensitive] is true then a case sensitive match is performed.
/// [caseSensitive] defaults to false.
///
/// If [recursive] is true then a recursive search of all subdirectories
///    (all the way down) is performed.
/// [recursive] is true by default.
///
/// [types] allows you to specify the file types you want the find to return.
/// By default [types] limits the results to files.
List<String> find(String pattern,
        {bool caseSensitive = false,
        bool recursive = true,
        String root = ".",
        List<FileSystemEntityType> types = const [
          FileSystemEntityType.file
        ]}) =>
    Find().find(pattern,
        caseSensitive: caseSensitive,
        recursive: recursive,
        root: root,
        types: types);

class Find extends Command {
  List<String> find(String pattern,
      {bool caseSensitive = false,
      bool recursive = true,
      String root = ".",
      List<FileSystemEntityType> types = const [FileSystemEntityType.file]}) {
    List<String> files = List();

    if (Settings().debug_on) {
      Log.d(
          "find: pwd: ${pwd} ${absolute(root)} pattern: ${pattern} caseSensitive: ${caseSensitive} recursive: ${recursive} types: ${types} ");
    }

    // scan current directory for files
    util.FileList(Directory(root), pattern, caseSensitive: caseSensitive,
        notify: (path) {
      FileSystemEntityType type = FileSystemEntity.typeSync(path);
      if (types.contains(type) ||
          (recursive && type == FileSystemEntityType.directory)) {
        files.add(path);
      }
    });

    if (recursive) {
      List<String> foundList = List();
      files.forEach((found) {
        FileSystemEntityType type = FileSystemEntity.typeSync(found);

        if (type == FileSystemEntityType.directory) {
          // recursive call to find.
          List<String> subDirList = find(pattern,
              caseSensitive: caseSensitive,
              recursive: recursive,
              root: join(root, found),
              types: types);

          foundList.addAll(subDirList);

          if (Settings().debug_on) {
            Log.d("find: found ${foundList.length}");
          }
        }
      });
      files.addAll(foundList);
    }

    // Remove directories unless explicity requested.
    // When recursing we need to artificually add the directories
    // to the list so we can visit each one.

    if (!types.contains(FileSystemEntityType.directory)) {
      files.retainWhere(
          (file) => types.contains(FileSystemEntity.typeSync(file)));
    }
    return files;
  }
}
