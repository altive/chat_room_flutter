import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:altive_chat_room/src/message_link.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('parseMessageLinks', () {
    final fixture =
        jsonDecode(
              File(
                'contract/fixtures/linkified-messages.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    final cases = fixture['cases']! as List<Object?>;

    for (final value in cases) {
      final testCase = value! as Map<String, Object?>;
      test(testCase['name']! as String, () {
        final links = parseMessageLinks(
          testCase['text']! as String,
        ).map((segment) => segment.link).whereType<MessageLink>().toList();
        final expectedLinks = (testCase['links']! as List<Object?>)
            .cast<Map<String, Object?>>();

        expect(links, hasLength(expectedLinks.length));
        for (var index = 0; index < links.length; index++) {
          expect(links[index].text, expectedLinks[index]['text']);
          expect(
            links[index].destination.toString(),
            expectedLinks[index]['destination'],
          );
          expect(links[index].kind.name, expectedLinks[index]['kind']);
        }
      });
    }

    test('複数リンクと改行を元の順序と文字列のまま保持する', () {
      const text = 'Web: example.com?q=1&lang=ja\nMail: user@example.jp';
      final segments = parseMessageLinks(text);
      final links = segments
          .map((segment) => segment.link)
          .whereType<MessageLink>()
          .toList();

      expect(segments.map((segment) => segment.text).join(), text);
      expect(links.map((link) => link.destination.toString()), [
        'https://example.com?q=1&lang=ja',
        'mailto:user@example.jp',
      ]);
    });

    test('未対応schemeに続くドメインを部分的にリンク化しない', () {
      final links = parseMessageLinks(
        'javascript:example.com',
      ).map((segment) => segment.link).whereType<MessageLink>();

      expect(links, isEmpty);
    });
  });

  testWidgets('通常本文、画像caption、システム本文のリンクを操作できる', (tester) async {
    await initializeDateFormatting('en');
    final launchedUris = <Uri>[];
    debugSetMessageUriLauncher((uri) async {
      launchedUris.add(uri);
      return true;
    });
    addTearDown(() => debugSetMessageUriLauncher(null));
    await _pumpRoom(
      tester,
      ChatTextMessage(
        id: 'text',
        createdAt: DateTime(2026),
        sender: _user,
        text: 'support@example.com',
      ),
    );
    _linkRecognizers(tester)['support@example.com']!.onTap!.call();
    await tester.pump();
    expect(launchedUris, [Uri.parse('mailto:support@example.com')]);

    await _pumpRoom(
      tester,
      ChatImagesMessage(
        id: 'image',
        createdAt: DateTime(2026),
        sender: _user,
        imageUrls: const ['https://example.com/image.jpg'],
        caption: '電話 090-1234-5678',
      ),
    );
    expect(_linkRecognizers(tester), contains('090-1234-5678'));

    await _pumpRoom(
      tester,
      ChatSystemMessage(
        id: 'system',
        createdAt: DateTime(2026),
        text: '連絡 sms:+819012345678',
      ),
    );
    final systemLink = _linkRecognizers(tester)['sms:+819012345678']!;
    debugSetMessageUriLauncher((_) => throw Exception('起動失敗'));
    systemLink.onTap!.call();
    await tester.pump();
    expect(tester.takeException(), isNull);

    final phoneLink = parseMessageLinks('090-1234-5678').single.link!;
    final context = tester.element(find.byType(AltiveChatRoom));
    debugSetMessageUriLauncher((uri) async {
      launchedUris.add(uri);
      return true;
    });
    unawaited(openMessageLink(context, phoneLink));
    await tester.pumpAndSettle();
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('SMS'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();
    expect(launchedUris.last, Uri.parse('tel:09012345678'));

    unawaited(openMessageLink(context, phoneLink));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SMS'));
    await tester.pumpAndSettle();
    expect(launchedUris.last, Uri.parse('sms:09012345678'));

    unawaited(openMessageLink(context, phoneLink));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsNothing);

    // ネットワーク画像の読み込みタイマーを残さずにテストを終了する。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
  });
}

const _user = ChatUser(
  id: 'me',
  name: '自分',
  avatarImageUrl: 'https://example.com/avatar.png',
);

Future<void> _pumpRoom(WidgetTester tester, ChatMessage message) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'me',
            messages: [message],
            onSendIconPressed: (_) {},
          ),
        ),
      ),
    );

Map<String, TapGestureRecognizer> _linkRecognizers(WidgetTester tester) {
  final links = <String, TapGestureRecognizer>{};

  void visitSpan(InlineSpan span) {
    if (span case TextSpan(:final text, :final recognizer)) {
      if (text != null && recognizer is TapGestureRecognizer) {
        links[text] = recognizer;
      }
      span.children?.forEach(visitSpan);
    }
  }

  for (final widget in tester.allWidgets) {
    switch (widget) {
      case Text(:final textSpan?):
        visitSpan(textSpan);
      case SelectableText(:final textSpan?):
        visitSpan(textSpan);
    }
  }
  return links;
}
