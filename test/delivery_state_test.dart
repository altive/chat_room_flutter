import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('送信失敗アイコンから同じメッセージIDで再送する', (tester) async {
    String? retriedMessageId;
    final message = ChatTextMessage(
      id: 'failed-message',
      createdAt: DateTime(2026, 8, 26, 12),
      sender: const ChatUser(id: 'me', name: 'Me', avatarImageUrl: 'data:'),
      text: 'message',
      deliveryState: ChatMessageDeliveryState.failed,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 600,
          child: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'me',
            messages: [message],
            onSendIconPressed: (_) {},
            onRetryMessage: (messageId) => retriedMessageId = messageId,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.error_outline));

    expect(retriedMessageId, 'failed-message');
  });

  testWidgets('新しい画像タップAPIへメッセージIDと位置を渡す', (tester) async {
    ({String messageId, int index})? tapped;
    final message = ChatImagesMessage(
      id: 'images-message',
      createdAt: DateTime(2026, 8, 26, 12),
      sender: const ChatUser(id: 'me', name: 'Me', avatarImageUrl: 'data:'),
      imageUrls: const ['data:image/png;base64,iVBORw0KGgo='],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 600,
          child: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'me',
            messages: [message],
            onSendIconPressed: (_) {},
            onImageTap: ({required messageId, required index}) {
              tapped = (messageId: messageId, index: index);
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Image));

    expect(tapped, (messageId: 'images-message', index: 0));
  });
}
