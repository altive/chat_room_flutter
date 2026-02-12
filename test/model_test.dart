import 'package:altive_chat_room/src/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatTextMessage', () {
    test('isSentByCurrentUser は sender.id 一致で true / 不一致で false を返す', () {
      final message = ChatTextMessage(
        id: 'm1',
        createdAt: DateTime(2026, 2, 9),
        sender: _user(id: 'u1'),
        text: 'hello',
      );

      expect(message.isSentByCurrentUser('u1'), isTrue);
      expect(message.isSentByCurrentUser('u2'), isFalse);
    });

    test('copyWith は指定項目のみ更新し、未指定項目は維持する', () {
      final base = ChatTextMessage(
        id: 'm1',
        createdAt: DateTime(2026, 2, 9),
        sender: _user(id: 'u1'),
        text: 'before',
        button: const MessageActionButton(text: 'open', value: 1),
        replyTo: ChatTextMessage(
          id: 'reply1',
          createdAt: DateTime(2026, 2, 8),
          sender: _user(id: 'u2'),
          text: 'reply',
        ),
        replyImageIndex: 0,
      );

      final updated = base.copyWith(text: 'after', highlight: true);

      expect(updated.id, base.id);
      expect(updated.createdAt, base.createdAt);
      expect(updated.sender, base.sender);
      expect(updated.text, 'after');
      expect(updated.highlight, isTrue);
      expect(updated.button, base.button);
      expect(updated.replyTo, base.replyTo);
      expect(updated.replyImageIndex, base.replyImageIndex);
      expect(updated.label, base.label);
    });
  });

  group('ChatImagesMessage', () {
    test('copyWith は画像関連フィールドを更新できる', () {
      final base = ChatImagesMessage(
        id: 'm2',
        createdAt: DateTime(2026, 2, 9),
        sender: _user(id: 'u1'),
        imageUrls: const ['a.jpg', 'b.jpg'],
        selectedImageIndex: 0,
      );

      final updated = base.copyWith(
        imageUrls: const ['x.jpg', 'y.jpg'],
        selectedImageIndex: 1,
      );

      expect(updated.imageUrls, const ['x.jpg', 'y.jpg']);
      expect(updated.selectedImageIndex, 1);
      expect(updated.sender, base.sender);
      expect(updated.label, base.label);
    });
  });

  group('ChatStickerMessage', () {
    test('copyWith は sticker を更新できる', () {
      final base = ChatStickerMessage(
        id: 'm4',
        createdAt: DateTime(2026, 2, 9),
        sender: _user(id: 'u1'),
        sticker: const Sticker(id: 1, imageUrl: 'a.png'),
      );

      final updated = base.copyWith(
        sticker: const Sticker(id: 2, imageUrl: 'b.png'),
      );

      expect(updated.sticker.id, 2);
      expect(updated.sticker.imageUrl, 'b.png');
      expect(updated.sender, base.sender);
      expect(updated.label, base.label);
    });
  });

  group('VoiceCallType', () {
    test('text は通話種別と送信者種別に応じた文言を返す', () {
      expect(
        VoiceCallType.connected.text(isSentByCurrentUser: true),
        'Voice call',
      );
      expect(
        VoiceCallType.connected.text(isSentByCurrentUser: false),
        'Voice call',
      );
      expect(
        VoiceCallType.unanswered.text(isSentByCurrentUser: true),
        'No answer',
      );
      expect(
        VoiceCallType.unanswered.text(isSentByCurrentUser: false),
        'Missed call',
      );
    });
  });

  group('ChatVoiceCallMessage', () {
    test('copyWith は connected の durationSeconds を更新できる', () {
      final base = ChatVoiceCallMessage(
        id: 'm5',
        createdAt: DateTime(2026, 2, 9),
        sender: _user(id: 'u1'),
        voiceCallType: VoiceCallType.connected,
        durationSeconds: 60,
      );

      final updated = base.copyWith(durationSeconds: 120);

      expect(updated.voiceCallType, VoiceCallType.connected);
      expect(updated.durationSeconds, 120);
      expect(updated.sender, base.sender);
      expect(updated.label, base.label);
    });

    test('copyWith は unanswered へ変更時に assertion になる', () {
      final base = ChatVoiceCallMessage(
        id: 'm6',
        createdAt: DateTime(2026, 2, 9),
        sender: _user(id: 'u1'),
        voiceCallType: VoiceCallType.connected,
        durationSeconds: 60,
      );

      expect(
        () => base.copyWith(voiceCallType: VoiceCallType.unanswered),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('ChatSystemMessage', () {
    test('copyWith は指定項目のみ更新し、未指定項目は維持する', () {
      final base = ChatSystemMessage(
        id: 's1',
        createdAt: DateTime(2026, 2, 9),
        text: 'before',
      );

      final updated = base.copyWith(text: 'after');

      expect(updated.id, base.id);
      expect(updated.createdAt, base.createdAt);
      expect(updated.text, 'after');
    });
  });

  group('ChatUser', () {
    test('copyWith は指定項目のみ更新し、未指定項目は維持する', () {
      const base = ChatUser(
        id: 'u1',
        name: 'before',
        avatarImageUrl: 'https://example.com/a.png',
      );

      final updated = base.copyWith(
        name: 'after',
        isOwner: true,
        avatarImageUrl: 'https://example.com/b.png',
      );

      expect(updated.id, base.id);
      expect(updated.name, 'after');
      expect(updated.isOwner, isTrue);
      expect(updated.avatarImageUrl, 'https://example.com/b.png');
    });

    test(
      'アバター指定がない場合は assertion になる',
      () {
        expect(
          () => ChatUser(id: 'u1', name: 'name'),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });

  group('PopupMenuLayout', () {
    test('buttonItems が空の場合は assertion になる', () {
      expect(
        () => PopupMenuLayout(column: 1, buttonItems: const []),
        throwsA(isA<AssertionError>()),
      );
    });

    test('buttonItems 件数が column で割り切れない場合は assertion になる', () {
      expect(
        () => PopupMenuLayout(
          column: 2,
          buttonItems: [
            PopupMenuButtonItem(
              iconWidget: const SizedBox.shrink(),
              onTap: (_) {},
            ),
          ],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('有効な入力で生成できる', () {
      final layout = PopupMenuLayout(
        column: 2,
        buttonItems: [
          PopupMenuButtonItem(
            title: 'A',
            iconWidget: const SizedBox.shrink(),
            onTap: (_) {},
          ),
          PopupMenuButtonItem(
            title: 'B',
            iconWidget: const SizedBox.shrink(),
            onTap: (_) {},
          ),
        ],
      );

      expect(layout.column, 2);
      expect(layout.buttonItems.length, 2);
    });
  });

  group('MessageInputType', () {
    test('期待する enum 値を持つ', () {
      expect(
        MessageInputType.values,
        const [MessageInputType.text, MessageInputType.sticker],
      );
    });
  });

  group('MessageActionButton', () {
    test('text または value が異なる場合は等価にならない', () {
      const base = MessageActionButton(text: 'Open', value: 1);
      const differentText = MessageActionButton(text: 'Close', value: 1);
      const differentValue = MessageActionButton(text: 'Open', value: 2);

      expect(base == differentText, isFalse);
      expect(base == differentValue, isFalse);
    });

    test('同一内容なら == / hashCode が一致する', () {
      const a = MessageActionButton(text: 'Open', value: 1);
      const b = MessageActionButton(text: 'Open', value: 1);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('PopupMenuButtonItem', () {
    test('onTap に渡したコールバックが実行される', () {
      ChatUserMessage? tappedMessage;
      final item = PopupMenuButtonItem(
        title: 'Reply',
        iconWidget: const Icon(Icons.reply),
        onTap: (message) {
          tappedMessage = message;
        },
      );
      final message = ChatTextMessage(
        id: 'm-popup',
        createdAt: DateTime(2026, 2, 9),
        sender: _user(id: 'u1'),
        text: 'hello',
      );

      item.onTap(message);

      expect(tappedMessage, same(message));
    });
  });

  group('StickerPackage', () {
    test('id または tabStickerImageUrl が異なる場合は等価にならない', () {
      const stickers = <Sticker>[
        Sticker(id: 1, imageUrl: 'https://example.com/a.png'),
      ];
      const base = StickerPackage(
        id: 10,
        tabStickerImageUrl: 'https://example.com/tab.png',
        stickers: stickers,
      );
      const differentId = StickerPackage(
        id: 11,
        tabStickerImageUrl: 'https://example.com/tab.png',
        stickers: stickers,
      );
      const differentTab = StickerPackage(
        id: 10,
        tabStickerImageUrl: 'https://example.com/other-tab.png',
        stickers: stickers,
      );

      expect(base == differentId, isFalse);
      expect(base == differentTab, isFalse);
    });

    test('同一内容なら == / hashCode が一致する', () {
      const stickers = <Sticker>[
        Sticker(id: 1, imageUrl: 'https://example.com/a.png'),
      ];
      const a = StickerPackage(
        id: 1,
        tabStickerImageUrl: 'https://example.com/tab.png',
        stickers: stickers,
      );
      const b = StickerPackage(
        id: 1,
        tabStickerImageUrl: 'https://example.com/tab.png',
        stickers: stickers,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Sticker', () {
    test('id または imageUrl が異なる場合は等価にならない', () {
      const base = Sticker(id: 7, imageUrl: 'https://example.com/s7.png');
      const differentId = Sticker(
        id: 8,
        imageUrl: 'https://example.com/s7.png',
      );
      const differentImage = Sticker(
        id: 7,
        imageUrl: 'https://example.com/s8.png',
      );

      expect(base == differentId, isFalse);
      expect(base == differentImage, isFalse);
    });

    test('同一内容なら == / hashCode が一致する', () {
      const a = Sticker(id: 1, imageUrl: 'https://example.com/a.png');
      const b = Sticker(id: 1, imageUrl: 'https://example.com/a.png');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}

ChatUser _user({required String id}) => ChatUser(
  id: id,
  name: 'User $id',
  avatarImageUrl: 'https://example.com/$id.png',
);
