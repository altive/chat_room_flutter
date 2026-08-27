import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('前後の空白を除去して送信直後に入力欄を空にする', (tester) async {
    String? sentText;
    await tester.pumpWidget(
      MaterialApp(
        home: AltiveChatRoom(
          theme: const AltiveChatRoomTheme(),
          currentUserId: 'me',
          messages: const [],
          showSendButtonInTextField: true,
          onSendIconPressed: (value) => sentText = value.text,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '  Hello\n');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(sentText, 'Hello');
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('空白だけの本文は送信しない', (tester) async {
    var sendCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AltiveChatRoom(
          theme: const AltiveChatRoomTheme(),
          currentUserId: 'me',
          messages: const [],
          showSendButtonInTextField: true,
          onSendIconPressed: (_) => sendCount += 1,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), ' \n\t ');
    await tester.pump();

    expect(find.byIcon(Icons.send), findsNothing);
    expect(sendCount, 0);
  });

  testWidgets('UTF-16上限で結合文字を分割せず入力を丸める', (tester) async {
    String? sentText;
    await tester.pumpWidget(
      MaterialApp(
        home: AltiveChatRoom(
          theme: const AltiveChatRoomTheme(),
          currentUserId: 'me',
          messages: const [],
          showSendButtonInTextField: true,
          draftPolicy: const ChatDraftPolicy(
            maximumLength: 3,
            warningThreshold: 2,
            lengthUnit: ChatDraftLengthUnit.utf16,
          ),
          onSendIconPressed: (value) => sentText = value.text,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'A😀B');
    await tester.pump();

    expect(find.text('A😀'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(sentText, 'A😀');
  });
}
