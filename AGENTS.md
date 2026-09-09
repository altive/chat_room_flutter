# Altive Chat エージェントガイド

## 常時適用するルール

- 会話、ドキュメント、コードコメント、テスト名は日本語で記述する。
- 既存の未コミット変更を尊重し、依頼と無関係な差分を変更・削除・コミットしない。
- `contract/chat-ui-contract.md`を、ライブラリと利用アプリの責務分担の正本とする。
- タスク完了前に差分をセルフレビューし、変更対象に関連するformat、lint、build、testを行う。
  文書・コメントだけの変更では参照・形式・差分を確認し、実行コードへの影響がなければ
  アプリ全体のbuildや依存revision更新を要求しない。
- タスク完了後は、依頼単位の適切な粒度とConventional Commitsでコミットする。
- `main`をpushするときは、直接`git push`せず`make push_main`を使う。このコマンドが
  未コミット差分、branch、remoteとの差分を検査し、安全にpushできない状態を拒否する。

## 変更時に読む仕様

- 仕様の入口: `contract/README.md`
- 責務・操作契約: `contract/chat-ui-contract.md`
- プラットフォーム別の対応状況: `contract/feature-matrix.md`
- モジュール配置と互換性方針: `contract/repository-architecture.md`
- 機能を変更する場合は、入口から該当する機能別契約とfixtureを確認する。

## 公開ライブラリの境界

- 公開API、表示状態、操作結果、アクセシビリティの意味を各プラットフォームで揃える。
  未対応機能や既存互換上の差はfeature matrixへ明記し、実装済みと計画を混同しない。
- 認証、保存、権限、課金、外部データ取得、navigationは利用アプリに委譲する。
  ライブラリへは表示値とcallbackを渡し、アプリ固有のStore、Repository、SDKを持ち込まない。
- 公開文書はこのリポジトリの仕様、サンプル、fixtureだけで理解できるようにする。
  非公開repositoryや特定製品の画面を仕様の必須参照・正本にしない。
- 製品別の導入計画、社内checkout配置、組織内の横断反映・リリース手順はここへ記載しない。
  公開PR、コメント、commit messageにも同じ境界を適用する。
- 利用アプリの改修は明示された作業範囲で扱う。このライブラリへの貢献に、非公開の
  利用アプリへのアクセスや変更を要求しない。
- パッケージ名、既存API名、fixture schemaは文書整理だけを理由に変更しない。

## 検証

- Flutter: `make flutter_verify`。golden対象は`make flutter_golden_test`。
- SwiftUI: `make swift_verify`。iOS固有の入力変更ではiOS Simulatorの回帰testも確認する。
- Android / Compose: `make android_verify`。
- 全プラットフォーム: `make verify`。
- baselineは意図した表示を確認した場合だけ更新する。実行できない検証は未実施と報告する。

## 完了報告

- 変更内容、互換性への影響、実行した検証と結果、commitまたはPR、未対応事項をまとめる。
- 利用側の追加作業が必要な場合は、一般的な移行条件として示す。未確認の利用アプリへ
  自動反映されたものと扱わない。
