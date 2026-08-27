import 'package:flutter/material.dart';

/// 削除確認で使用する文言。
@immutable
class ChatDeletionConfirmationStrings {
  /// 削除確認で使用する文言を作成する。
  const ChatDeletionConfirmationStrings({
    required this.title,
    required this.deleteButton,
    required this.cancelButton,
    this.message,
  });

  /// 確認タイトル。
  final String title;

  /// 削除ボタン。
  final String deleteButton;

  /// キャンセルボタン。
  final String cancelButton;

  /// 確認本文。
  final String? message;
}

/// 共通の削除確認ダイアログを表示し、削除が選ばれたか返す。
///
/// 権限判定と実際の削除処理は呼び出し側が所有する。
Future<bool> showChatDeletionConfirmation({
  required BuildContext context,
  required ChatDeletionConfirmationStrings strings,
}) async {
  final message = strings.message;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.cancelButton),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.deleteButton),
        ),
      ],
    ),
  );
  return result ?? false;
}
