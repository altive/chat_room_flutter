# altive_chat_room

`altive_chat_room` は、チャット画面を構築するための Flutter UI パッケージです。
ダイレクトチャット / グループチャットの表示に対応し、テキスト・画像・スタンプ・システムメッセージを扱えます。

## 特徴

- すぐに利用できるチャット画面ウィジェット: `AltiveChatRoom`
- 対応メッセージ種別:
  - `ChatTextMessage`
  - `ChatImagesMessage`
  - `ChatStickerMessage`
  - `ChatVoiceCallMessage`
  - `ChatSystemMessage`
- `AltiveChatRoomTheme` によるテーマカスタマイズ
- メッセージバブル / ポップアップメニュー / アクションの拡張コールバック

## できること

- チャット画面をそのまま導入できる
- 1対1チャットとグループチャットの両方を表示できる
- 文字・画像・スタンプ・お知らせメッセージを送受信画面に表示できる
- スタンプ一覧から選んで送信できる
- メッセージを長押ししたときのメニュー（返信・コピーなど）を設定できる
- アバターや画像タップ時の動作を自由に設定できる
- 色や文字サイズ、吹き出しデザインなど見た目を調整できる
- 引っ張って更新、送信中表示、空状態表示などの基本UXに対応できる

## Getting Started

本リポジトリの前提:

- Dart SDK: `^3.10.4`
- Flutter package 構成

未公開状態で別プロジェクトからローカル参照する場合:

```yaml
dependencies:
  altive_chat_room:
    path: ../altive_chat_room
```

## 使い方

最小構成の例:

```dart
import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    const me = ChatUser(id: '1', name: 'Me');
    const other = ChatUser(id: '2', name: 'Other');

    final messages = <ChatMessage>[
      ChatTextMessage(
        id: 'm1',
        createdAt: DateTime.now(),
        sender: other,
        text: 'Hello!',
      ),
    ];

    return AltiveChatRoom(
      theme: const AltiveChatRoomTheme(),
      myUserId: me.id,
      messages: messages,
      onSendIconPressed: (value) {
        // 送信処理
      },
    );
  }
}
```

詳細なサンプルは `example/lib/main.dart` を参照してください。

## 開発

```bash
flutter pub get
flutter analyze
flutter test
```

example の起動:

```bash
cd example
flutter pub get
flutter run
```
