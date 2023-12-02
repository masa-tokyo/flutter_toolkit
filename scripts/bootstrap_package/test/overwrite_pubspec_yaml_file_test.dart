import 'package:bootstrap_package/overwrite_pubspec_yaml_file.dart';
import 'package:test/test.dart';

void main() {
  test('getDartCaretVersion', () {
    final versionString = getDartCaretVersion();

    expect(versionString, isNotNull);
    expect(versionString, startsWith('^'));
    expect(versionString, endsWith('.0'));
  });
}
