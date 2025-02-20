import 'run_command.dart';
import 'run_dart.dart';
import 'run_flutter.dart';

/// [runCommand]の最後に実行する関数
void finalizeSetup({required PackageType packageType}) {
  // 生成したシンボリックリンクを同期させる
  switch (packageType) {
    case PackageType.dart:
      runDart(['pub', 'get']);
    case PackageType.flutter:
      runFlutter(['pub', 'get']);
  }

  // 生成されたパッケージ内のファイルを整形
  runDart(['format', '.']);
}
