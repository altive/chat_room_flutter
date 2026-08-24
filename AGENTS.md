# Altive Chat エージェントガイド

## 常時適用するルール

- 会話、ドキュメント、コードコメント、テスト名は日本語で記述する。
- 既存の未コミット変更を尊重し、依頼と無関係な差分を変更・削除・コミットしない。
- `contract/chat-ui-contract.md`を、ライブラリと利用アプリの責務分担の正本とする。
- タスク完了前に差分をセルフレビューし、関連するformat、lint、build、testを行う。
- タスク完了後は、依頼単位の適切な粒度とConventional Commitsでコミットする。

## Fanely・Nokorisへの横断反映

- 利用アプリの正本repositoryは、Fanelyが`altive/fanely`、Nokorisが
  `altive/nokoris`である。Nokorisはアプリ名、`restock`はローカルcheckoutの
  directory名として扱う。
- 利用アプリへ変更を加える前に、既存checkoutのtop-levelと`origin`が正本repositoryを
  指すことを確認する。アプリ名からcheckout pathを推測してcloneしない。正本checkoutが
  見つからない、または`origin`が一致しない場合は、代替checkoutを作成せず作業を止めて
  報告する。
- AltiveChatのユーザー向け機能、UI、操作契約、公開APIを追加・変更・修正する場合は、
  ユーザーが対象アプリを明示的に限定しない限り、FanelyとNokorisの両方を
  同一タスクの対象とする。
- 最初に`contract/chat-ui-contract.md`で責務を判定する。ライブラリ責務の変更は
  AltiveChatへ実装してから両アプリへ適用し、Store、Repository、Firebase接続、
  navigation、画面外タップなどアプリ責務の変更は、両アプリ側へ同等に実装する。
- 両アプリでは各リポジトリの`AGENTS.md`に従い、対象OSが限定されていない限り、
  それぞれが提供するiOS・Androidへ同等の状態、操作結果、validationを反映する。
- AltiveChatのpushだけで利用アプリへ自動反映されたものと扱わない。両アプリで
  依存revisionまたはlockfileを更新し、必要なadapter・backendを接続して、
  build、test、画面確認まで完了する。
- 一方のアプリまたはOSが非該当の場合は、利用箇所を検索した根拠と影響を完了報告へ
  記載する。対象リポジトリへアクセスできない場合や必要な判断が不足する場合は、
  片方だけで完了扱いにせず、未完了事項として報告する。

## 完了報告

- AltiveChat、Fanely、Nokorisごとに、変更内容、依存revision、実行した検証、
  commit、未対応事項をまとめる。
- Firebase Rules、indexes、Functionsなどのデプロイ対象がある場合は、アプリごとに
  対象ファイル、環境付きコマンド、後方互換性、推奨デプロイ順を記載する。
