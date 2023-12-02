import 'dart:io';

/// 例外全般をターミナル上に表示するための関数
///
/// `[ERROR]`ラベルと共にエラー内容とスタックトレースを表示し、[exitCode]を1にする。
void showException(Exception e, StackTrace s) {
  stderr
    ..writeln('[ERROR] $e')
    ..writeln(s);
  exitCode = 1;
}
