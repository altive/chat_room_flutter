import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('システムメッセージをタイムライン中央に表示する', (tester) async {
    await initializeDateFormatting('en');
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'me',
            messages: [
              ChatSystemMessage(
                id: 'deleted-message',
                createdAt: DateTime(2026),
                text: 'このメッセージは削除されました',
              ),
            ],
            onSendIconPressed: (_) {},
          ),
        ),
      ),
    );

    final messageCenter = tester.getCenter(find.text('このメッセージは削除されました'));
    expect(messageCenter.dx, closeTo(200, 0.5));
  });
}
