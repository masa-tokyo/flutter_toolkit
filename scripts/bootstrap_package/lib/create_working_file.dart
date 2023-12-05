import 'dart:io';

import 'package:path/path.dart' as path;

/// 作業用ファイルを作成するための関数
///
/// srcディレクトリへファイルを作成し、lib直下のファイルにそのpathへのexport文を記載する。
void createWorkingFile({required String packageName}) {
  // srcディレクトリへファイルを作成
  final baseFileName = '$packageName.dart';
  File(path.join('lib/src', baseFileName)).createSync(recursive: true);

  // lib直下のファイルへexport文を記載
  final exportStatement = '''
export 'src/$baseFileName';
''';
  File(path.join('lib', baseFileName)).writeAsStringSync(exportStatement);
}
