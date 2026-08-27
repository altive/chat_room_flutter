import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const strings = ChatDeletionConfirmationStrings(
    title: 'メッセージを削除しますか？',
    message: 'この操作は取り消せません。',
    deleteButton: '削除',
    cancelButton: 'キャンセル',
  );

  testWidgets('削除を選ぶとtrueを返す', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showChatDeletionConfirmation(
                context: context,
                strings: strings,
              );
            },
            child: const Text('開く'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    expect(find.text(strings.title), findsOneWidget);
    expect(find.text(strings.message!), findsOneWidget);

    await tester.tap(find.text(strings.deleteButton));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('キャンセルを選ぶとfalseを返す', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showChatDeletionConfirmation(
                context: context,
                strings: strings,
              );
            },
            child: const Text('開く'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.cancelButton));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
