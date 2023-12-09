import 'dart:io';

/// Dartコマンド実行用関数
///
/// 実行環境に応じてfvmコマンドを付与するかを判断した上でDartコマンドを実行する。
ProcessResult runDart(
  List<String> arguments,
) {
  if (Platform.environment['GITHUB_ACTIONS'] == 'true') {
    return Process.runSync(
      'dart',
      arguments,
    );
  } else {
    return Process.runSync(
      'fvm',
      [
        'dart',
        ...arguments,
      ],
    );
  }
}
