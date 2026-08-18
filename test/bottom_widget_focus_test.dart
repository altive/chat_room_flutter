import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('入力欄にフォーカスが当たると先頭ボタンを閉じる', (tester) async {
    await tester.pumpWidget(_testApp());

    expect(find.byKey(const Key('先頭ボタン')), findsOneWidget);
    expect(find.byKey(const Key('展開ボタン')), findsNothing);

    final textField = tester.widget<TextField>(find.byType(TextField));
    textField.focusNode!.requestFocus();
    await tester.pump();

    expect(find.byKey(const Key('先頭ボタン')), findsNothing);
    expect(find.byKey(const Key('展開ボタン')), findsOneWidget);
  });

  testWidgets('展開ボタンを押すとフォーカス中でも先頭ボタンを再表示する', (tester) async {
    await tester.pumpWidget(_testApp());

    final textField = tester.widget<TextField>(find.byType(TextField));
    textField.focusNode!.requestFocus();
    await tester.pump();

    await tester.tap(find.byKey(const Key('展開ボタン')));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'メッセージ');
    await tester.pump();

    expect(find.byKey(const Key('先頭ボタン')), findsOneWidget);
    expect(find.byKey(const Key('展開ボタン')), findsNothing);
  });
}

Widget _testApp() {
  return MaterialApp(
    home: Scaffold(
      body: AltiveChatRoom(
        theme: const AltiveChatRoomTheme(),
        currentUserId: 'current-user',
        messages: const [],
        onSendIconPressed: (_) {},
        expandButtonIcon: const Icon(
          Icons.arrow_forward_ios,
          key: Key('展開ボタン'),
        ),
        bottomLeadingWidgets: [
          IconButton(
            key: const Key('先頭ボタン'),
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    ),
  );
}
