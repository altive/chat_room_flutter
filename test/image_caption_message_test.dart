import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('画像と本文を同じメッセージ行に表示する', (tester) async {
    await initializeDateFormatting('en');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'me',
            messages: [
              ChatImagesMessage(
                id: 'message-1',
                createdAt: DateTime(2026),
                sender: const ChatUser(
                  id: 'me',
                  name: '自分',
                  avatarImageUrl: 'https://example.com/avatar.png',
                ),
                imageUrls: const ['https://example.com/image.jpg'],
                caption: '故障した画面です',
              ),
            ],
            onSendIconPressed: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('故障した画面です'), findsOneWidget);

    // ネットワーク画像の読み込みタイマーを残さずにテストを終了する。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
  });
}
