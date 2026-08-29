import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  const sender = ChatUser(
    id: 'user-1',
    name: '送信者',
    defaultAvatarImageAssetPath: 'assets/avatar.png',
  );

  test('返信参照は元メッセージを入れ子にせず本文だけを保持する', () {
    final nested = ChatTextMessage(
      id: 'older',
      createdAt: DateTime(2025),
      sender: sender,
      text: '古い本文',
    );
    final message = ChatTextMessage(
      id: 'message-1',
      createdAt: DateTime(2026),
      sender: sender,
      text: '本文',
      replyTo: nested,
    );

    final reference = message.toReplyReference();

    expect(reference.messageId, 'message-1');
    expect(reference.senderId, sender.id);
    expect(reference.content, const ChatReplyTextPreview('本文'));
  });

  test('画像返信のindexを範囲内へ正規化する', () {
    final message = ChatImagesMessage(
      id: 'message-1',
      createdAt: DateTime(2026),
      sender: sender,
      imageUrls: const ['https://example.com/1', 'https://example.com/2'],
      caption: '説明',
    );

    final selected = message.toReplyReference(imageIndex: 1);
    expect(selected.imageIndex, 1);
    expect(
      selected.content,
      const ChatReplyImagePreview(
        thumbnailUrl: 'https://example.com/2',
        caption: '説明',
        totalCount: 2,
      ),
    );

    final fallback = message.toReplyReference(imageIndex: 9);
    expect(fallback.imageIndex, isNull);
    expect(
      fallback.content,
      const ChatReplyImagePreview(
        thumbnailUrl: 'https://example.com/1',
        caption: '説明',
        totalCount: 2,
      ),
    );
  });

  test('新しい返信参照を互換用メッセージより優先する', () {
    const current = ChatReplyReference(
      messageId: 'current',
      senderId: 'user-1',
      senderDisplayName: '送信者',
      content: ChatReplyTextPreview('新しい本文'),
    );
    final legacy = ChatTextMessage(
      id: 'legacy',
      createdAt: DateTime(2025),
      sender: sender,
      text: '古い本文',
    );
    final message = ChatTextMessage(
      id: 'message-1',
      createdAt: DateTime(2026),
      sender: sender,
      text: '返信',
      replyTo: legacy,
      replyReference: current,
    );

    expect(message.effectiveReplyReference, current);
  });

  test('submissionへ返信参照を保持する', () {
    const reference = ChatReplyReference(
      messageId: 'target',
      senderId: 'user-1',
      senderDisplayName: '送信者',
      content: ChatReplyTextPreview('返信元'),
    );
    const submission = ChatComposerSubmission(text: '返信', replyTo: reference);

    expect(submission.replyTo, reference);
  });

  test('App固有変換では送信中メッセージを返信可能にできない', () {
    final message = ChatTextMessage(
      id: 'sending',
      createdAt: DateTime(2026),
      sender: sender,
      text: '送信中',
      deliveryState: ChatMessageDeliveryState.sending,
    );
    const fallback = ChatReplyReference(
      messageId: 'sending',
      senderId: 'user-1',
      senderDisplayName: '送信者',
      content: ChatReplyLabelPreview('カスタム'),
    );
    final configuration = ChatReplyConfiguration(
      makeReference: (_, _) => fallback,
    );

    expect(configuration.referenceFor(message), isNull);
  });

  testWidgets('長押しで返信を選びsubmissionへ含めて送信後に消す', (tester) async {
    await initializeDateFormatting();
    ChatComposerSubmission? sent;
    final target = ChatTextMessage(
      id: 'target',
      createdAt: DateTime(2026),
      sender: sender,
      text: '返信元本文',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 600,
          child: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'user-1',
            messages: [target],
            replyConfiguration: const ChatReplyConfiguration(),
            onSubmit: (submission) => sent = submission,
            onSendIconPressed: (_) {},
          ),
        ),
      ),
    );

    await tester.longPress(find.text('返信元本文'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();

    expect(find.text('返信元本文'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField), '返信本文');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(sent?.replyTo?.messageId, 'target');
    expect(sent?.text, '返信本文');
    expect(find.text('返信元本文'), findsOneWidget);
  });

  testWidgets('ステッカー送信にも選択中の返信参照を含める', (tester) async {
    await initializeDateFormatting();
    tester.view
      ..physicalSize = const Size(800, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ChatComposerSubmission? sent;
    final target = ChatTextMessage(
      id: 'target',
      createdAt: DateTime(2026),
      sender: sender,
      text: '返信元本文',
    );
    const sticker = Sticker(
      id: 1,
      imageUrl: 'data:image/png;base64,iVBORw0KGgo=',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 800,
          child: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'user-1',
            messages: [target],
            replyConfiguration: const ChatReplyConfiguration(),
            textFieldSuffixBuilder: (_) => const Icon(
              Icons.emoji_emotions_outlined,
              key: Key('ステッカー入力切替'),
            ),
            stickerPackages: const [
              StickerPackage(
                id: 1,
                tabStickerImageUrl: 'data:image/png;base64,iVBORw0KGgo=',
                stickers: [sticker],
              ),
            ],
            onSubmit: (submission) => sent = submission,
            onSendIconPressed: (_) {},
          ),
        ),
      ),
    );

    await tester.longPress(find.text('返信元本文'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reply'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ステッカー入力切替')));
    await tester.pumpAndSettle();
    final stickerItem = find.byKey(const Key('AltiveChatRoom.Sticker.1'));
    tester.widget<GestureDetector>(stickerItem).onTap!.call();
    await tester.pump();
    final stickerPreview = find.byKey(
      const Key('AltiveChatRoom.StickerPreview'),
    );
    tester.widget<GestureDetector>(stickerPreview).onTap!.call();
    await tester.pump();

    expect(sent?.sticker, sticker);
    expect(sent?.replyTo?.messageId, 'target');
    expect(find.text('返信元本文'), findsOneWidget);
  });
}
