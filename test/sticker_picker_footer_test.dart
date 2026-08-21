import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('狭い画面でもスタンプを4列表示する', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'current-user',
            messages: const [],
            onSendIconPressed: (_) {},
            textFieldSuffixBuilder: (_) => const Icon(
              Icons.emoji_emotions_outlined,
              key: Key('スタンプ入力切替'),
            ),
            stickerPackages: [
              StickerPackage(
                id: 1,
                tabStickerImageUrl: 'https://example.com/tray.png',
                stickers: List.generate(
                  4,
                  (index) => Sticker(
                    id: index,
                    imageUrl: 'https://example.com/sticker-$index.png',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('スタンプ入力切替')));
    await tester.pump();

    final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);

    await tester.pump(const Duration(seconds: 11));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('横幅に余裕がある場合はスタンプの列数を増やす', (tester) async {
    tester.view
      ..physicalSize = const Size(834, 1194)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'current-user',
            messages: const [],
            onSendIconPressed: (_) {},
            textFieldSuffixBuilder: (_) => const Icon(
              Icons.emoji_emotions_outlined,
              key: Key('スタンプ入力切替'),
            ),
            stickerPackages: [
              StickerPackage(
                id: 1,
                tabStickerImageUrl: 'https://example.com/tray.png',
                stickers: List.generate(
                  12,
                  (index) => Sticker(
                    id: index,
                    imageUrl: 'https://example.com/sticker-$index.png',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('スタンプ入力切替')));
    await tester.pump();

    final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, greaterThan(4));

    await tester.pump(const Duration(seconds: 11));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('スタンプ一覧を最下部までスクロールすると末尾Widgetを表示する', (tester) async {
    final stickers = List.generate(
      24,
      (index) => Sticker(
        id: index,
        imageUrl: 'https://example.com/sticker-$index.png',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AltiveChatRoom(
            theme: const AltiveChatRoomTheme(),
            currentUserId: 'current-user',
            messages: const [],
            onSendIconPressed: (_) {},
            textFieldSuffixBuilder: (_) => const Icon(
              Icons.emoji_emotions_outlined,
              key: Key('スタンプ入力切替'),
            ),
            stickerPackages: [
              StickerPackage(
                id: 1,
                tabStickerImageUrl: 'https://example.com/tray.png',
                stickers: stickers,
              ),
            ],
            stickerPickerFooter: const SizedBox(
              key: Key('スタンプ一覧末尾'),
              height: 80,
              child: Text('LINEスタンプ配信中'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('スタンプ入力切替')));
    await tester.pump();

    expect(find.byKey(const Key('スタンプ一覧末尾')), findsNothing);

    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -1000),
    );
    await tester.pump();

    expect(find.byKey(const Key('スタンプ一覧末尾')), findsOneWidget);

    await tester.pump(const Duration(seconds: 11));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
