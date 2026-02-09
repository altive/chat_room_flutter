# altive_chat_room_example

`altive_chat_room` パッケージの利用例を確認するためのサンプルアプリです。
Direct / Group の2タブで、主要なチャットUI機能を動作確認できます。

## 確認できる内容

- テキスト / 画像 / スタンプ / システムメッセージの表示
- 送信アクション (`onSendIconPressed`)
- 長押しポップアップメニュー (`PopupMenuLayout`)
- スタンプ選択UI (`stickerPackages`)
- Pull-to-Refresh / スクロール最上部検知
- 各種コールバック（アバタータップ、画像タップ、スタンプタップなど）

## 起動方法

```bash
cd example
flutter pub get
flutter run
```

Web で確認する場合:

```bash
cd example
flutter run -d chrome
```

## 主要ファイル

- `example/lib/main.dart`: サンプル画面本体
- `example/assets/avatar.png`: サンプル用アバター画像
- `example/pubspec.yaml`: 依存関係・アセット定義
