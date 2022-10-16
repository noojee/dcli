/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli_core/dcli_core.dart' hide exists, Settings;
import 'package:posix/posix.dart' as posix;

import '../../dcli.dart';

/// Sets the permissions on a file on posix systems.
///
/// [permission] is an octal string as used by the cli commandchmod e.g. 777
/// [path] is the path to the file that we are changing the
/// permissions of.
///
/// The [permission] digits are intrepeted as owner, group, other.
/// So:
/// 641
/// owner - 6
/// group - 4
/// other - 1
///
/// Each digit is the sum of the permissions:
/// 4 - allow read
/// 2 - allow write
/// 1 - all execute
///
/// So 6 is 4 + 2 is read and write and from the above example gives the owner r/w permission.
///
/// To set give the owner execution privileges use:
/// ```dart
/// chmod('/path/to/exe', permission: '100');
/// ```
/// If [path] doesn't exist a ChModException] is thrown.
///
/// On Windows a call to this method is a noop.
///
void chmod(String path, {required String permission}) =>
    _ChMod()._chmod(path, permission);

/// Implementatio for [chmod] function.
class _ChMod extends DCliFunction {
// this.user, this.group, this.other, this.path

  void _chmod(String path, String permission) {
    if (!exists(path)) {
      throw ChModException('The file at ${truepath(path)} does not exists');
    }
    if (!Settings().isWindows) {
      if (posix.isPosixSupported) {
        posix.chmod(path, permission);
      } else {
        'chmod $permission "$path"'.run;
      }
    }
  }

  //  String chmod({int user, int group, int other, this.path}) {}

/*  String buildPermission(int permission) {
    bool read = ((permission & 4) >> 2) == 1;
    bool write = ((permission & 2) >> 1) == 1;
    bool execute = ((permission & 1)) == 1;
  }
  */
}

/// Thrown if the [chmod] function encounters an error.
class ChModException extends DCliFunctionException {
  /// Thrown if the [chmod] function encounters an error.
  ChModException(super.reason, [super.stacktrace]);

  // @override
  // DCliException copyWith(core.StackTraceImpl stackTrace) =>
  //     ChModException(message, stackTrace);
}
