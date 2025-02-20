import 'dart:io';

import 'run_command.dart';
import 'run_dart.dart';

/// [runCommand]の最後に実行する関数
void finalizeSetup({
  required PackageType packageType,
  required bool enableWorkspace,
  required String packageName,
}) {
  if (enableWorkspace) {
    stdout.writeln('''
Pub Workspace を有効化するために、以下のようにパッケージを追加してください。
```yaml
workspace:
  - packages/$packageName
```
その後、`melos bs`コマンドにより、生成したシンボリックリンクやパッケージのバージョンを同期してください。''');
  } else {
    // 生成したシンボリックリンクやパッケージのバージョンを同期させる
    Process.runSync('melos', ['bootstrap']);
  }

  // 生成されたパッケージ内のファイルを整形
  runDart(['format', '.']);
}
