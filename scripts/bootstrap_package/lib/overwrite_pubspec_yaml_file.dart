import 'dart:io';

import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import 'bs_package_exception.dart';
import 'run_dart.dart';
import 'run_flutter.dart';

/// pubspec.yamlファイルを上書き作成するための関数
///
/// プロジェクト作成段階から以下の箇所を修正：
/// - sdkバージョンはmelos.yaml同様に最新stableをキャレット記号にて記述
/// - flutterバージョンは削除
/// - flutter_lintsを削除
/// - 不要なhomepageフィールドの削除
/// - 不要なコメントの削除
/// - 意図しない配信を避けるためpublish_toフィールドを追加
/// - uses-material-designフィールドを追加
/// - [isWorkspace] に応じてresolutionフィールドを追加
/// - [dependencies], [devDependencies] を依存関係へ追加
void overwritePubspecYamlFile({
  required String packageName,
  required String description,
  required List<String> dependencies,
  required List<String> devDependencies,
  required bool isWorkspace,
}) {
  final dartVersion = getDartCaretVersion();
  final resolution = isWorkspace ? '  resolution: workspace\n' : '';

  final content = '''
name: $packageName
description: $description
publish_to: 'none'
version: 0.0.1
$resolution
environment:
  sdk: $dartVersion
resolution: workspace

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
''';

  File('pubspec.yaml').writeAsStringSync(content);

  // dependencies を追加
  for (final dependency in dependencies) {
    runFlutter(['pub', 'add', dependency]);
  }

  // devDependencies を追加
  for (final devDependency in devDependencies) {
    runFlutter(['pub', 'add', '--dev', devDependency]);
  }
}

/// pubspec.yamlに記載するdart sdkのバージョンを取得する関数
///
/// FVMのdart versionを取得し、そのバージョンをキャレット記号にて記述する。
/// 尚、pubspec.yamlファイル作成後に`melos bs`コマンドを実行しても同様の結果になるが、
/// コマンドの実行時間削減のためにこのように実装している。
@visibleForTesting
String getDartCaretVersion() {
  final versionResult = runDart(['--version']);
  final versionOutput = versionResult.stdout as String;

  final versionMatch = RegExp(
    r'Dart SDK version: (\d+\.\d+\.\d+)',
  ).firstMatch(versionOutput);
  final versionString = versionMatch?.group(1);
  if (versionString == null) {
    throw BsPackageException('''Dartバージョンの取得に失敗しました。
`fvm dart --version`コマンドの実行結果内に「Dart SDK version: 1.2.3」という形式の文字列が見つかりませんでした。
正規表現の変更を検討してください。

コマンド実行結果:
$versionOutput''');
  }
  final version = Version.parse(versionString);
  // melos.yamlの記述内容と揃えるために、patchバージョンは0としておく
  return '^${version.major}.${version.minor}.0';
}
