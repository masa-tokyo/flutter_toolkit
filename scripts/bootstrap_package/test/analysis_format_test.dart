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
    print('packageResult.exitCode: ${packageResult.exitCode}');

    // パッケージ生成後のanalysis_options.yamlのシンボリックリンクを同期させる
    final melosBsResult = Process.runSync(
      'melos',
      ['bs'],
    );

    expect(melosBsResult.exitCode, 0, reason: melosBsResult.stderr.toString());
    // テスト実行
    Directory.current = Directory(path.join('packages', packageName));
    final analysisResult = runDart(['analyze', '.']);
    expect(
      analysisResult.exitCode,
      0,
      reason:
          // ignore: lines_longer_than_80_chars
          '[ERROR]stderr:\n${analysisResult.stderr}\nstdout:\n${analysisResult.stdout}',
    );

    final formatResult = runDart(['format', '.']);
    expect(
      formatResult.exitCode,
      0,
      reason:
          // ignore: lines_longer_than_80_chars
          '[ERROR]stderr:\n${formatResult.stderr}\nstdout:\n${formatResult.stdout}',
    );

    // プロジェクトルートへ移動
    Directory.current = Directory('../..');

    final formattingResult = Process.runSync(
      '.github/workflows/scripts/validate-formatting.sh',
      [],
    );
    expect(
      formattingResult.exitCode,
      0,
      reason:
          // ignore: lines_longer_than_80_chars
          '[ERROR]stderr:\n${formattingResult.stderr}\nstdout:\n${formattingResult.stdout}',
    );

    // 生成パッケージを削除
    Directory(path.join('packages', packageName)).deleteSync(recursive: true);
  });
}
