import 'dart:io';

import 'package:path/path.dart' as path;

/// テスト用ファイルを上書き作成するための関数
///
/// プロジェクト作成段階のテストファイルに含まれているサンプル用のクラスが
/// その後の処理により削除されているため、テスト内容を空にした状態に修正する。
void overwriteTestFile({required String packageName}) {
  final content = '''
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('$packageName test', () {});
}
''';

  File(
    path.join('test', '${packageName}_test.dart'),
  ).writeAsStringSync(content);
}
