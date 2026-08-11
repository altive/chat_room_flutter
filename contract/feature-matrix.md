# Feature matrix

`implemented`はライブラリ単体で利用可能、`planned`は共通化対象だが未実装、
`app`はアプリ側の責務を表す。

| 機能 | Flutter | SwiftUI | Compose |
| --- | --- | --- | --- |
| テキストメッセージ | implemented | implemented | implemented |
| システムメッセージ | implemented | implemented | implemented |
| 画像メッセージ | implemented | implemented | planned |
| スタンプメッセージ | implemented | planned | planned |
| 音声通話メッセージ | implemented | planned | planned |
| 自分・相手の左右配置 | implemented | implemented | implemented |
| グループでの送信者名 | implemented | implemented | implemented |
| 送信中表示 | implemented | implemented | implemented |
| 送信失敗表示 | app | implemented | implemented |
| 失敗時の再送UI | app | implemented | implemented |
| テーマ | implemented | implemented | implemented |
| 空状態 | implemented | implemented | implemented |
| リプライ | implemented | planned | planned |
| リアクション候補・件数 | implemented | implemented | implemented |
| 長押しメニュー | implemented | implemented | implemented |
| UTF-16入力長方針 | app | implemented | implemented |
| スタンプpicker | implemented | implemented | implemented |
| アバター表示 | implemented | implemented | implemented |
| システムイベント展開 | app | implemented | implemented |
| 汎用タイムライン境界 | app | implemented | implemented |
| 過去メッセージ取得 | implemented | app | planned |
| 既読管理 | app | app | app |
| 永続化・実際の再送 | app | app | app |

Flutterの既存機能は維持する。SwiftUIまたはComposeへ未移植であることを理由に、
Flutterの公開APIを削除しない。
