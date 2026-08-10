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
| 失敗時の再送UI | app | implemented | planned |
| テーマ | implemented | implemented | planned |
| 空状態 | implemented | implemented | planned |
| リプライ | implemented | planned | planned |
| リアクション候補・件数 | implemented | implemented | planned |
| 長押しメニュー | implemented | implemented | planned |
| UTF-16入力長方針 | app | implemented | planned |
| スタンプpicker | implemented | implemented | planned |
| アバター表示 | implemented | implemented | planned |
| システムイベント展開 | app | implemented | planned |
| 汎用タイムライン境界 | app | implemented | planned |
| 過去メッセージ取得 | implemented | app | planned |
| 既読管理 | app | app | app |
| 永続化・実際の再送 | app | app | app |

Flutterの既存機能は維持する。SwiftUIまたはComposeへ未移植であることを理由に、
Flutterの公開APIを削除しない。
