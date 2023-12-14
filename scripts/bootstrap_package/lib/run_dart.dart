import 'dart:io';

import 'env.dart';

/// dartコマンド実行用関数
///
/// 実行環境に応じてfvmコマンドを付与するかを判断した上でdartコマンドを実行する。
ProcessResult runDart(
  List<String> arguments,
) {
  if (isGithubActionsEnv) {
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
