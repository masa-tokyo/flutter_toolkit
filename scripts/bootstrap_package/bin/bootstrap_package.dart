import 'package:bootstrap_package/run_command.dart';

/// 新規パッケージ作成用の関数
///
/// FDSプロジェクトのルートディレクトリから以下のコマンドにより実行する。
/// `fvm dart run bootstrap_package <パッケージ名>`
/// 実際の処理内容は[runCommand]に記述する。
void main(List<String> args) => runCommand(args);
