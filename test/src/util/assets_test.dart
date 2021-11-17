import 'dart:io';

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('Assets().toString', () async {
    final path = join('assets', 'templates', 'basic.dart');
    // ignore: deprecated_member_use_from_same_package
    final content = Assets().loadString(path);

    expect(content, isNotNull);

    var actual =
        read(join(DartProject.self.pathToProjectRoot, 'lib', 'src', path))
            .toList()
            .join(Platform().eol);

    /// the join trims the last \n
    actual += Platform().eol;

    expect(content, equals(actual));
  });

  test('Assets().list', () async {
    final path = join('assets', 'templates');
    // ignore: deprecated_member_use_from_same_package
    final templates = Assets().list('*', root: path);

    final base = join(DartProject.self.pathToProjectRoot, 'lib', 'src', path);

    expect(
      templates,
      unorderedEquals(
        <String>[
          join(base, 'basic.dart'),
          join(base, 'hello_world.dart'),
          join(base, 'README.md'),
          join(base, 'analysis_options.yaml.template'),
          join(base, 'pubspec.yaml.template'),
          join(base, 'cmd_args.dart')
        ],
      ),
    );
  });
}
