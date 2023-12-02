/// 本パッケージ専用の例外クラス
class BsPackageException implements Exception {
  BsPackageException(this.message);

  final String message;

  @override
  String toString() {
    return 'BsPackageException: $message';
  }
}
