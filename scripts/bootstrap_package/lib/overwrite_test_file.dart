import 'dart:io';

import 'package:path/path.dart' as path;

import 'run_command.dart';

/// テスト用ファイルを上書き作成するための関数
///
/// プロジェクト作成段階のテストファイルに含まれているサンプル用のクラスが
/// その後の処理により削除されているため、テスト内容を空にした状態に修正する。
void overwriteTestFile({
  required String packageName,
  required PackageType packageType,
}) {
  final testPackage = switch (packageType) {
    PackageType.dart => "import 'package:test/test.dart';",
    PackageType.flutter => "import 'package:flutter_test/flutter_test.dart';",
  };

  final content = '''
$testPackage

void main() {
  test('test', () {});
}
''';

  File(
    path.join('test', '${packageName}_test.dart'),
  ).writeAsStringSync(content);
}
