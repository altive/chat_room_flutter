# Altive Chat

Altive Chat は、Altive のアプリ間でチャット UI とその表示契約を共有するための
マルチプラットフォームライブラリです。

現在は次のパッケージを提供します。

- Flutter: `altive_chat_room`。既存アプリとの互換性を維持します。
- Swift: `AltiveChatCore` と `AltiveChatUI`。iOS 17 以降に対応します。
- Jetpack Compose: `chat-core` と `chat-ui-compose`。Fanely Android と同じ
  minSdk 26、compileSdk 37の構成です。

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
      currentUserId: me.id,
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

Swift Package Manager は次の2製品を提供します。

- `AltiveChatCore`: Foundationだけに依存する表示モデル、入力方針、送信状態、
  楽観的更新、最近使った項目の純粋な状態遷移。
- `AltiveChatUI`: `AltiveChatCore`を利用するSwiftUIコンポーネント。

SwiftUI版の見た目と操作感は、ファネリーの Family Room をデザイン上の正本とします。
吹き出し、入力欄、送信状態と再送導線、リアクションと長押し操作、ステッカーpicker、
アバター、システムイベントの展開、キーボードとスタンプ入力面のレイアウト計算を
共通コンポーネントとして提供します。各アプリ固有のStore、権限、外部I/O、課金、
画面遷移はパッケージへ持ち込みません。

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
ライブラリは再送ボタンや楽観的更新の純粋な状態遷移を提供しますが、実際の送信、
永続化、オフライン方針、ページングはアプリ側が担当します。

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
      draftPolicy: ChatDraftPolicy(
        maximumLength: 1_000,
        warningThreshold: 900,
        lengthUnit: .utf16
      ),
      onRetry: { messageID in
        // 同じoperation IDで再送
      },
      onSend: send
    )
  }
}
```

## Jetpack Compose

Android実装はFlutter exampleから独立した`android/` Gradle projectです。

- `chat-core`: UI frameworkに依存しない表示モデル、入力方針、送信状態、
  リアクションの楽観的更新、最近使った項目。
- `chat-ui-compose`: Room、Composer、再送UI、リアクション、ステッカーpicker、
  アバター、システムイベント、タイムライン境界。

開発中にFanely Androidから利用する場合は、Fanely側の`settings.gradle.kts`で
composite buildとして追加し、`jp.co.altive.chat:chat-core`と
`jp.co.altive.chat:chat-ui-compose`をprojectへ置換します。絶対pathは
local property等から注入し、リポジトリへcommitしません。正式配布時はMaven
repositoryへ`chat-core`と`chat-ui-compose`を公開します。

```kotlin
var draft by remember { mutableStateOf("") }

AltiveChatRoom(
  messages = messages,
  currentUserId = currentUserId,
  draft = draft,
  onDraftChange = { draft = it },
  draftPolicy = ChatDraftPolicy(
    maximumLength = 1_000,
    warningThreshold = 900,
    lengthUnit = ChatDraftLengthUnit.Utf16,
  ),
  onRetry = viewModel::retry,
  onSend = viewModel::send,
)
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

Android/Compose:

```bash
make android_verify
```

Flutter example の起動:

```bash
cd example
flutter pub get
flutter run
```
