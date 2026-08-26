import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _onePixelPng =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
    'AAAADUlEQVR42mNk+M/wHwAE/wJ/l4v2WQAAAABJRU5ErkJggg==';

void main() {
  test('単一画像は可変比率を既定とする', () {
    const configuration = ChatImageLayoutConfiguration();
    expect(configuration.singleImageLayout.isAdaptive, isTrue);
  });

  testWidgets('4枚超は2×2へ収めて超過件数を表示する', (tester) async {
    final message = ChatImagesMessage(
      id: 'five-images',
      createdAt: DateTime(2026, 8, 27),
      sender: const ChatUser(id: 'me', name: 'Me', avatarImageUrl: 'data:'),
      imageUrls: List.filled(5, _onePixelPng),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 700,
          child: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'me',
            messages: [message],
            onSendIconPressed: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('data URIからURLへ変わる画像はgapless表示を利用する', (tester) async {
    final notifier = ValueNotifier(_onePixelPng);
    addTearDown(notifier.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<String>(
          valueListenable: notifier,
          builder: (context, imageUrl, _) => AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'me',
            messages: [
              ChatImagesMessage(
                id: 'transition-image',
                createdAt: DateTime(2026, 8, 27),
                sender: const ChatUser(
                  id: 'me',
                  name: 'Me',
                  avatarImageUrl: 'data:',
                ),
                imageUrls: [imageUrl],
              ),
            ],
            onSendIconPressed: (_) {},
          ),
        ),
      ),
    );

    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .any((image) => image.gaplessPlayback),
      isTrue,
    );

    notifier.value = 'https://example.com/image.png';
    await tester.pump();

    expect(
      tester
          .widgetList<Image>(find.byType(Image))
          .any((image) => image.gaplessPlayback),
      isTrue,
    );
  });
}
