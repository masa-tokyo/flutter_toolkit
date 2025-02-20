import 'dart:io';

import 'package:bootstrap_package/env.dart';
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
    final packageResult = runDart([
      'run',
      'bootstrap_package',
      packageName,
      '-f',
      '--description',
      'This is a test package for analysis and format check.',
      // プロジェクトルートの analysis_options.yaml で採用している pedantic_mono を追加
      '-v',
      'pedantic_mono',
    ]);
    _expectNonErrorResult(packageResult);
    addTearDown(() {
      // テスト終了時点でのディレクトリの位置に依存しないように、絶対パスを指定して生成パッケージを削除
      final projectRootPath = _findProjectRoot();
      Directory(
        path.join(projectRootPath, 'packages', packageName),
      ).deleteSync(recursive: true);
    });
    // 生成パッケージへ移動
    Directory.current = Directory(path.join('packages', packageName));

    // `dart analyze`で指摘ゼロか検証
    final analysisResult = runDart(['analyze', '.']);
    _expectNonErrorResult(analysisResult);

    // `dart format`で修正が発生していないか検証
    final formatResult = runDart(['format', '.']);
    _expectNonErrorResult(formatResult);
    expect(formatResult.stdout, contains('(0 changed)'));
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

/// プロジェクトルートの絶対パスを取得するメソッド
String _findProjectRoot() {
  if (isGithubActionsEnv) {
    final githubWorkspace = Platform.environment['GITHUB_WORKSPACE'];
    expect(githubWorkspace, isNotNull);
    return githubWorkspace!;
  } else {
    var currentDirectory = Directory.current;
    // プロジェクトルートに存在するはずのmelos.yamlが見つかるまで親ディレクトリへ戻る
    while (!File(path.join(currentDirectory.path, 'melos.yaml')).existsSync()) {
      currentDirectory = currentDirectory.parent;
    }
    return currentDirectory.path;
  }
}
