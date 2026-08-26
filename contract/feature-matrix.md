# Feature matrix

`implemented`はライブラリ単体で利用可能、`planned`は共通化対象だが未実装、
`app`はアプリ側の責務を表す。

| 機能 | Flutter | SwiftUI | Compose |
| --- | --- | --- | --- |
| テキストメッセージ | implemented | implemented | implemented |
| メッセージ内リンク・連絡先 | implemented | implemented | implemented |
| システムメッセージ | implemented | implemented | implemented |
| 汎用メッセージカード | implemented | implemented | implemented |
| 画像メッセージ | implemented | implemented | implemented |
| 画像＋本文の複合メッセージ | implemented | implemented | implemented |
| スタンプメッセージ | implemented | planned | planned |
| 音声通話メッセージ | implemented | planned | planned |
| 自分・相手の左右配置 | implemented | implemented | implemented |
| グループでの送信者名 | implemented | implemented | implemented |
| 送信中表示 | implemented | implemented | implemented |
| 送信失敗表示 | implemented | implemented | implemented |
| 失敗時の再送UI | implemented | implemented | implemented |
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
| Roomシェル・入力面配置 | app | implemented | implemented |
| 初期位置・末尾追従 | implemented | implemented | implemented |
| 最新付近のみ受信追従・自分送信は常に追従 | implemented | implemented | implemented |
| 最新へ移動ボタン | implemented | implemented | implemented |
| 手動・自動の履歴追加UI | implemented | implemented | implemented |
| 履歴追加時の位置保持 | implemented | implemented | implemented |
| 単一画像の高さ制限付き可変比率 | implemented | implemented | implemented |
| 複数画像レイアウト選択 | implemented | implemented | implemented |
| メッセージID＋画像位置のタップ通知 | implemented | implemented | implemented |
| ローカル画像からリモート画像への表示維持 | implemented | implemented | implemented |
| ステッカー入力のopt-in表示 | implemented | implemented | implemented |
| 日付・未読区切り | app | implemented | implemented |
| 削除確認UI | app | implemented | implemented |
| 過去メッセージ取得処理 | implemented | app | app |
| 既読管理 | app | app | app |
| 永続化・実際の再送 | app | app | app |

Flutterの既存機能は維持する。SwiftUIまたはComposeへ未移植であることを理由に、
Flutterの公開APIを削除しない。
