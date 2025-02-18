import 'dart:io';

/// 使い方をターミナル上に表示するための関数
///
/// helpオプションが指定された時や誤った使い方がされた時に用いる。
/// 誤った使い方がされた場合、[exitCode]を1にして[errorMessage]を表示する。
void showUsage({String? errorMessage}) {
  if (errorMessage != null) {
    exitCode = 1;
    stderr.writeln('[ERROR] $errorMessage');
  }

  const usage = '''
    
Usage: fvm dart run bootstrap_package <パッケージ名> [options]

Options:
-d, --description <パッケージ説明>             パッケージの説明を指定
-p, --dependencies <package1,package2>       作成するパッケージの dependencies へ追加したい外部パッケージを指定
-v, --dev_dependencies <package1,package2>   作成するパッケージの dev_dependencies へ追加したい外部パッケージを指定
-l, --license              　　　　　　　　　　　ルートディレクトリのライセンスへのシンボリックリンクを作成
-h, --help　　　　　　　                        使い方を表示

Example:
  fvm dart run bootstrap_package login_form -d "ログインフォーム用Flutterパッケージ"
    ''';
  stdout.writeln(usage);
}
