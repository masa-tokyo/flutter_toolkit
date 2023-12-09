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
    // TODO(masaki): delete after checking the absolute path
    // ignore_for_file: avoid_print

    print('current: ${Directory.current.path}');
    final workspacePath = Platform.environment['GITHUB_WORKSPACE'] ?? '';
    print('workspacePath: $workspacePath');
    // // プロジェクトルートへ移動
    Directory.current = Directory('../..');
    print('current: ${Directory.current.path}');

    // 一意な名前のパッケージを生成
    final now = DateTime.now().microsecondsSinceEpoch;
    final packageName = 'analysis_format_test_$now';
    if (Platform.environment['GITHUB_ACTIONS'] == 'true') {
      Process.runSync(
        'dart',
        [
          'run',
          'bootstrap_package',
          packageName,
          '-d',
          'This is a test package for analysis and format check.',
        ],
      );
    } else {
      Process.runSync(
        'fvm',
        [
          'dart',
          'run',
          'bootstrap_package',
          packageName,
          '-d',
          'This is a test package for analysis and format check.',
        ],
      );
    }
    final packageResult = runDart(
      [
        'run',
        'bootstrap_package',
        packageName,
        '-d',
        'This is a test package for analysis and format check.',
      ],
    );
    print('packageResult.exitCode: ${packageResult.exitCode}');

    print('current: ${Directory.current.path}');

    // テスト実行
    Process.runSync('melos', ['run', 'analyze']);
    Process.runSync('melos', ['run', 'format']);
    Process.runSync(
      path.join(
        '.github',
        'workflows',
        'scripts',
        'validate-formatting.sh',
      ),
      [],
    );

    // 生成パッケージを削除
    // check whether the package actually exists
    print('current: ${Directory.current.path}');
    if (Directory(path.join('packages', packageName)).existsSync()) {
      print('exists');
      Directory(path.join('packages', packageName)).deleteSync(recursive: true);
    } else {
      print('not exists');
    }
  });
}
