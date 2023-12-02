import 'dart:io';

import 'package:args/args.dart';
import 'package:bootstrap_package/show_exception.dart';
import 'package:bootstrap_package/show_usage.dart';
import 'package:path/path.dart' as path;

import 'create_working_file.dart';
import 'overwrite_pubspec_yaml_file.dart';
import 'overwrite_test_file.dart';

/// コマンド実行用関数
///
/// 問題が発生した場合には[exitCode]を0以外に設定して処理を終了する。
void runCommand(List<String> args) {
  try {
    // 引数を定義
    final parser = ArgParser()
      ..addOption(
        'description',
        abbr: 'd',
      )
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
      );
    final parsedArgs = parser.parse(args);

    // helpオプションが指定された場合、使い方を表示して処理を終了
    final shouldHelp = parsedArgs['help'] as bool;
    if (shouldHelp) {
      showUsage();
      return;
    }

    // パッケージ名が入力されていない場合、エラー文を表示して処理を終了
    final name = parsedArgs.rest.firstOrNull;
    if (name == null) {
      showUsage(errorMessage: 'パッケージ名を指定してください。');
      return;
    }

    // packagesディレクトリへ移動
    Directory.current = Directory('packages');

    // パッケージ用のプロジェクトを作成
    Process.runSync(
      'fvm',
      ['flutter', 'create', '-t', 'package', name],
    );

    // 作成されたパッケージへ移動
    Directory.current = Directory(name);

    createWorkingFile(packageName: name);

    // analysis_options.yamlを削除し、プロジェクトルートのものをsymbolic linkで追加
    final analysisOptionsFile = File('analysis_options.yaml')..deleteSync();
    Link(analysisOptionsFile.path)
        .createSync(path.join('../..', analysisOptionsFile.path));

    overwriteTestFile(packageName: name);

    // パッケージ説明が引数として指定されていない場合、パッケージ名から作成
    var description = parsedArgs['description'] as String?;
    description ??= '$name用Flutterパッケージ';

    overwritePubspecYamlFile(packageName: name, description: description);

    // 外部公開しないため不要なLICENSEファイルを削除
    File('LICENSE').deleteSync();

    // READMEファイルをパッケージ名のみに上書き
    final packageTitle = '# $name';
    File('README.md').writeAsStringSync(packageTitle);
  } on FormatException catch (_) {
    // '-d'のようなoptionコマンドに続く引数が入力されていない場合
    showUsage(errorMessage: 'オプションコマンドの使い方が間違っています。');
  } on Exception catch (e, s) {
    showException(e, s);
  }
}
