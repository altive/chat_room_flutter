import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('汎用メッセージカードの内容と読み上げラベルを表示する', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatMessageCard(
              style: ChatMessageCardStyle.celebration,
              isOwnMessage: false,
              accessibilityLabel: 'お祝いカード',
              header: Text('お誕生日おめでとう'),
              content: Text('すてきな一年になりますように'),
              footer: Text('補足'),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(RegExp('お祝いカード')), findsOneWidget);
    expect(find.text('お誕生日おめでとう'), findsOneWidget);
    expect(find.text('すてきな一年になりますように'), findsOneWidget);
    expect(find.text('補足'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('footerを省略して狭い幅でも本文を省略しない', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: ChatMessageCard(
              style: ChatMessageCardStyle.celebration,
              isOwnMessage: true,
              accessibilityLabel: 'お祝いカード',
              header: Text('おめでとう'),
              content: Text('長いメッセージもカードの高さを伸ばしてすべて表示します。'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('長いメッセージもカードの高さを伸ばしてすべて表示します。'), findsOneWidget);
    expect(find.text('補足'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'celebrationカードのlight外観を固定する',
    (tester) async {
      tester.view
        ..physicalSize = const Size(390, 360)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorSchemeSeed: Colors.orange),
          home: const Scaffold(
            body: RepaintBoundary(
              key: Key('message-card-golden'),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ChatMessageCard(
                      style: ChatMessageCardStyle.celebration,
                      isOwnMessage: false,
                      accessibilityLabel: 'Celebration card',
                      header: Text(
                        'Happy birthday, Alex!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text('Wishing you a wonderful year ahead.'),
                    ),
                    SizedBox(height: 20),
                    ChatMessageCard(
                      style: ChatMessageCardStyle.celebration,
                      isOwnMessage: true,
                      accessibilityLabel: 'Celebration card',
                      header: Text(
                        'Congratulations!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text('This card includes a footer.'),
                      footer: Text('From your family'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(const Key('message-card-golden')),
        matchesGoldenFile('goldens/chat_message_card.png'),
      );
    },
    tags: 'golden',
  );
}
