import 'dart:io';

import 'package:bootstrap_package/run_dart.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

/// コードの質が担保されているかをテストする関数
///
/// 本パッケージ内の実装に際して問題が起こっていた場合に事前に気づけるように、
/// 実際にパッケージを生成した上でテストを実行する。
void main() {
  test('Analysis format test', () {
    // プロジェクトルートへ移動
    Directory.current = Directory('../..');

    // 一意な名前のパッケージを生成
    final now = DateTime.now().microsecondsSinceEpoch;
    final packageName = 'analysis_format_test_$now';
    final packageResult = runDart(
      [
        'run',
        'bootstrap_package',
        packageName,
        '-d',
        'This is a test package for analysis and format check.',
      ],
    );
    _expectNonErrorResult(packageResult);

    // 生成パッケージへ移動
    Directory.current = Directory(path.join('packages', packageName));

    // テスト実行
    final analysisResult = runDart(['analyze', '.']);
    _expectNonErrorResult(analysisResult);

    final formatResult = runDart(['format', '.']);
    _expectNonErrorResult(formatResult);
    expect(
      formatResult.stdout,
      contains('(0 changed)'),
    );

    // 生成パッケージを削除
    Directory.current.deleteSync(recursive: true);
  });
}

/// [ProcessResult]がエラーで終了していないことを確認するメソッド
void _expectNonErrorResult(ProcessResult result) {
  expect(
    result.exitCode,
    0,
    reason: '''
エラー内容:
${result.stderr}
出力内容:
${result.stdout}
''',
  );
}
