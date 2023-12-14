import 'dart:io';

/// 実行環境がGithub Actionsかどうか
final isGithubActionsEnv = Platform.environment['GITHUB_ACTIONS'] == 'true';
