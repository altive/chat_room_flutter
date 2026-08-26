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

  testWidgets('失敗メッセージがpendingにも含まれる場合は失敗表示を優先する', (tester) async {
    final message = ChatTextMessage(
      id: 'failed-and-pending',
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
            pendingMessageIds: const ['failed-and-pending'],
            onSendIconPressed: (_) {},
            onRetryMessage: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.timelapse), findsNothing);
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

    final imageTile = find.byWidgetPredicate(
      (widget) =>
          widget.key is GlobalObjectKey &&
          (widget.key! as GlobalObjectKey).value == 'img_images-message_0',
    );
    final detector = find.descendant(
      of: imageTile,
      matching: find.byType(GestureDetector),
    );
    tester.widget<GestureDetector>(detector).onTap!.call();

    expect(tapped, (messageId: 'images-message', index: 0));
  });
}
