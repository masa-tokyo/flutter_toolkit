import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'create_working_file.dart';
import 'finalize_setup.dart';
import 'overwrite_pubspec_yaml_file.dart';
import 'overwrite_test_file.dart';
import 'run_dart.dart';
import 'run_flutter.dart';
import 'show_exception.dart';
import 'show_usage.dart';

/// コマンド実行用関数
///
/// 問題が発生した場合には[exitCode]を0以外に設定して処理を終了する。
void runCommand(List<String> args) {
  try {
    // 引数を定義
    final parser =
        ArgParser()
          ..addFlag('help', abbr: 'h', negatable: false)
          ..addFlag('dart', abbr: 'd', negatable: false)
          ..addFlag('flutter', abbr: 'f', negatable: false)
          ..addFlag('workspace', abbr: 'w')
          ..addFlag('license', abbr: 'l')
          ..addMultiOption('dependencies', abbr: 'p')
          ..addMultiOption('dev_dependencies', abbr: 'v')
          ..addOption('description');
    final parsedArgs = parser.parse(args);

    // helpオプションが指定された場合、使い方を表示して処理を終了
    final shouldHelp = parsedArgs['help'] as bool;
    if (shouldHelp) {
      showUsage();
      return;
    }

    final packageTypeResult = PackageType.fromParsedArgs(parsedArgs);
    // 不適切な引数の渡し方をされている場合、エラー文を表示して処理を終了
    if (packageTypeResult.errorMessage != null) {
      showUsage(errorMessage: packageTypeResult.errorMessage);
      return;
    }
    final packageType = packageTypeResult.value!;

    // パッケージ名が入力されていない場合、エラー文を表示して処理を終了
    final name = parsedArgs.rest.firstOrNull;
    if (name == null) {
      showUsage(errorMessage: 'パッケージ名を指定してください。');
      return;
    }

    // packagesディレクトリへ移動
    Directory.current = Directory('packages');

    // パッケージ用のプロジェクトを作成
    switch (packageType) {
      case PackageType.dart:
        runDart(['create', '-t', 'package', name]);
      case PackageType.flutter:
        runFlutter(['create', '-t', 'package', name]);
    }

    // 作成されたパッケージへ移動
    Directory.current = Directory(name);

    createWorkingFile(packageName: name);

    // analysis_options.yamlを削除し、プロジェクトルートのものをsymbolic linkで追加
    final analysisOptionsFile = File('analysis_options.yaml')..deleteSync();
    Link(
      analysisOptionsFile.path,
    ).createSync(path.join('../..', analysisOptionsFile.path));

    overwriteTestFile(packageName: name, packageType: packageType);

    // パッケージ説明が引数として指定されていない場合、パッケージ名から作成
    var description = parsedArgs['description'] as String?;
    description ??= switch (packageType) {
      PackageType.dart => '$name用 Dart パッケージ',
      PackageType.flutter => '$name用 Flutter パッケージ',
    };

    final dependencies = List<String>.from(parsedArgs['dependencies'] as List);
    final devDependencies = List<String>.from(
      parsedArgs['dev_dependencies'] as List,
    );
    final enableWorkspace = parsedArgs['workspace'] as bool;
    overwritePubspecYamlFile(
      packageName: name,
      description: description,
      dependencies: dependencies,
      devDependencies: devDependencies,
      enableWorkspace: enableWorkspace,
      packageType: packageType,
    );

    // LICENSEファイル削除し、プロジェクトルートのものをsymbolic linkで追加
    final licenseFile = File('LICENSE')..deleteSync();
    final shouldAddLicense = parsedArgs['license'] as bool;
    if (shouldAddLicense) {
      Link(licenseFile.path).createSync(path.join('../..', licenseFile.path));
    }

    // READMEファイルをパッケージ名のみに上書き
    final packageTitle = '# $name';
    File('README.md').writeAsStringSync(packageTitle);

    finalizeSetup();
  } on FormatException catch (_) {
    // '-d'のようなoptionコマンドに続く引数が入力されていない場合
    showUsage(errorMessage: 'オプションコマンドの使い方が間違っています。');
  } on Exception catch (e, s) {
    showException(e, s);
  }
}

enum PackageType {
  dart,
  flutter;

  const PackageType();

  static ({PackageType? value, String? errorMessage}) fromParsedArgs(
    ArgResults parsedArgs,
  ) {
    final isFlutterPackage = parsedArgs['flutter'] as bool;
    final isDartPackage = parsedArgs['dart'] as bool;

    // パッケージの種類が選択されていない場合
    if (!isFlutterPackage && !isDartPackage) {
      return (value: null, errorMessage: 'パッケージの種類を指定してください。');
    }

    // パッケージの種類が両方指定されている場合
    if (isFlutterPackage && isDartPackage) {
      return (value: null, errorMessage: 'パッケージの種類は1つだけ指定してください。');
    }

    assert(isFlutterPackage || isDartPackage);

    if (isFlutterPackage) {
      return (value: PackageType.flutter, errorMessage: null);
    } else {
      return (value: PackageType.dart, errorMessage: null);
    }
  }
}
