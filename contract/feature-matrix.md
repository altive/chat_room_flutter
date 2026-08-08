# Feature matrix

`implemented`はライブラリ単体で利用可能、`planned`は共通化対象だが未実装、
`app`はアプリ側の責務を表す。

| 機能 | Flutter | SwiftUI | Compose |
| --- | --- | --- | --- |
| テキストメッセージ | implemented | implemented | planned |
| システムメッセージ | implemented | implemented | planned |
| 画像メッセージ | implemented | planned | planned |
| スタンプメッセージ | implemented | planned | planned |
| 音声通話メッセージ | implemented | planned | planned |
| 自分・相手の左右配置 | implemented | implemented | planned |
| グループでの送信者名 | implemented | implemented | planned |
| 送信中表示 | implemented | implemented | planned |
| 送信失敗表示 | app | implemented | planned |
| テーマ | implemented | implemented | planned |
| 空状態 | implemented | implemented | planned |
| リプライ | implemented | planned | planned |
| 長押しメニュー | implemented | planned | planned |
| 過去メッセージ取得 | implemented | app | planned |
| 既読管理 | app | app | app |
| 永続化・再送 | app | app | app |

Flutterの既存機能は維持する。SwiftUIまたはComposeへ未移植であることを理由に、
Flutterの公開APIを削除しない。
