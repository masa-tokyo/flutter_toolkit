import 'dart:io';

import 'package:path/path.dart' as path;

/// 作業用ファイルを作成するための関数
///
/// srcディレクトリへファイルを作成し、lib直下のファイルにそのpathへのexport文を記載する。
void createWorkingFile({
  required String packageName,
  required String description,
}) {
  // srcディレクトリへファイルを作成
  final baseFileName = '${packageName}_base.dart';
  File(path.join('lib/src', baseFileName)).createSync(recursive: true);

  // lib直下のファイルへパッケージの説明とexport文を記載
  final exportStatement = '''
/// $description
library;

export 'src/$baseFileName';
''';
  File(
    path.join('lib', '$packageName.dart'),
  ).writeAsStringSync(exportStatement);
}
