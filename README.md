# Altive Chat

Altive Chat は、Altive のアプリ間でチャット UI とその表示契約を共有するための
マルチプラットフォームライブラリです。

現在は次のパッケージを提供します。

- Flutter: `altive_chat_room`。既存アプリとの互換性を維持します。
- SwiftUI: `AltiveChatUI`。iOS 17 以降に対応します。
- Jetpack Compose: 将来追加する予定です。

プラットフォーム間で共有する責務と機能差は、
[`contract/chat-ui-contract.md`](contract/chat-ui-contract.md) と
[`contract/feature-matrix.md`](contract/feature-matrix.md) を正本とします。

## Flutter

Flutter パッケージは従来どおりリポジトリルートの `lib/`、`test/`、`example/` に
配置しています。既存利用側の `path` dependency と import path は変更しません。

### 特徴

- チャット画面ウィジェット: `AltiveChatRoom`
- テキスト、画像、スタンプ、音声通話、システムメッセージ
- `AltiveChatRoomTheme` によるテーマカスタマイズ
- メッセージバブル、ポップアップメニュー、アクションの拡張コールバック

### ローカル参照

```yaml
dependencies:
  altive_chat_room:
    path: ../chat_room_flutter
```

### 使い方

最小構成の例:

```dart
import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    const me = ChatUser(
      id: '1',
      name: 'Me',
      avatarImageUrl: 'https://example.com/avatar_me.png',
    );
    const other = ChatUser(
      id: '2',
      name: 'Other',
      avatarImageUrl: 'https://example.com/avatar_other.png',
    );

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

## SwiftUI

Swift Package Manager のライブラリ製品名と import 名は `AltiveChatUI` です。

リポジトリ名変更と最初の SemVer tag 公開後は、次のURLから追加します。

```swift
.package(
  url: "https://github.com/altive/altive-chat.git",
  from: "0.1.0"
)
```

リリース前にローカルで統合する場合は、利用側の `Package.swift` から参照します。

```swift
.package(path: "../chat_room_flutter")
```

最小構成では、表示するメッセージと入力中テキストをアプリ側が所有します。
送信、永続化、再送、ページングなどの業務処理はライブラリへ持ち込みません。

```swift
import AltiveChatUI
import SwiftUI

struct ChatScreen: View {
  @State private var draft = ""

  let messages: [ChatMessage]
  let currentUserID: String
  let send: (String) -> Void

  var body: some View {
    AltiveChatRoom(
      messages: messages,
      currentUserID: currentUserID,
      draft: $draft,
      onSend: send
    )
  }
}
```

## 開発

両方をまとめて検証:

```bash
make verify
```

Flutter:

```bash
make flutter_verify
```

SwiftUI:

```bash
make swift_verify
```

Flutter example の起動:

```bash
cd example
flutter pub get
flutter run
```
