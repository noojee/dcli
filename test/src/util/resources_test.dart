
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/dcli/resources/generated/resource_registry.dart';
import 'package:dcli/src/util/file_sync.dart';
import 'package:dcli/src/util/resources.dart';
import 'package:test/test.dart';

const filename = 'PXL_20211104_224740653.jpg';

void main() {
  test('resources ...', () async {
    Resources().pack();
  });

  test('unpack', () {
    final jpegResource = ResourceRegistry.resources[filename];
    expect(jpegResource, isNotNull);

    withTempFile((file) {
      final root = Resources().resourceRoot;
      final pathTo = join(root, filename);
      final originalHash = calculateHash(pathTo);
      jpegResource!.unpack(file);
      final unpackedHash = calculateHash(file);
      expect(originalHash, equals(unpackedHash));
    });

    // for (var resource in ResourceRegistry.resources)
    // {

    // }
  });
}
