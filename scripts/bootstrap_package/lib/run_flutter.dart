import 'dart:io';

import 'env.dart';

/// flutterコマンド実行用関数
///
/// 実行環境に応じてfvmコマンドを付与するかを判断した上でflutterコマンドを実行する。
ProcessResult runFlutter(List<String> arguments) {
  if (isGithubActionsEnv) {
    return Process.runSync('flutter', arguments);
  } else {
    return Process.runSync('fvm', ['flutter', ...arguments]);
  }
}
