# Link preview contract

## 目的

テキストメッセージ本文の先頭Web URLを、送信前と送信後に共通のリンクプレビューとして
表示する。AltiveChatはFirebaseや外部サイトへ接続せず、利用アプリが検証した表示値と
画像loaderだけを受け取る。

本書は公開モデル、UI契約、resolverと画像loaderを実装する呼び出し側の前提を定義する。
取得・保存の具体的なbackend構成は利用アプリが管理し、非公開の仕様へのアクセスを
本ライブラリの利用条件にしない。

## 対象

- `ChatMessageContent.text` / `ChatTextMessage`に含まれる先頭のWeb URL 1件
- 入力中のdraft preview
- 送信済み・送信中テキストメッセージのpreview card
- SwiftUI、Jetpack Compose、Flutterの同等な状態、操作結果、アクセシビリティ

画像caption、システムメッセージ、汎用カード、メールアドレス、電話番号にはpreviewを
表示しない。本文中のリンク化と外部遷移は既存のメッセージ内リンク契約を維持する。

## 責務

AltiveChatが所有する。

- 共通parserによる先頭Web URLの選択
- 500ミリ秒debounce、loading、URL変更時の古い結果破棄
- previewの表示モデル、カードレイアウト、theme、画像なしfallback
- card tap、読み上げ順、Dynamic Type / font scaling、light / dark theme
- resolver失敗中も本文編集と送信を継続する状態遷移

利用アプリが所有する。

- resolver callbackからデータ取得処理を呼ぶことと、必要な認証・認可
- scope所属、rate limit、外部URL取得時のSSRF対策
- OGP等のmetadata取得、cache、画像変換、保存と永続化
- app固有schemaとAltiveChat表示モデルの変換
- 画像resourceの解決、アクセス権の検証、端末cache
- URLを開くnavigation方針と失敗処理

AltiveChatはHTTP client、HTML parser、Firebase SDK、product固有IDを依存へ追加しない。
端末からの直接OGP取得は提供せず、previewを利用アプリから受け取る。

## 呼び出し側の安全条件

- resolverへ渡される本文URLと取得metadataは信頼しない。HTTP(S)のURL、文字数、画像寸法などを
  検証し、未対応・破損データはpreviewなし、または画像なしへ変換する。
- backendで外部URLを取得する場合、内部・ローカル宛先へのアクセス、redirect、応答量、
  timeoutを含む取得制限とSSRF対策を呼び出し側で実施する。UIのURL検出は安全性の保証ではない。
- 認証情報や保存先の内部構造を表示modelへ含めない。画像resourceは不透明な参照として渡し、
  読み取り権限や認証付き取得は画像loader側で解決する。
- draft previewは楽観表示用であり、保存可能な信頼済みmetadataとして扱わない。
  永続化時の再検証、cacheの共有範囲、保持・削除方針は利用アプリが決定する。
- 取得不能・拒否・検証失敗ではpreviewなしへfallbackし、通常の本文送信と表示を継続する。

これらはライブラリと呼び出し側の境界であり、特定backendの実装手順や安全性監査の代替ではない。

## 表示モデル

3platformで次の意味を持つ値型を公開する。言語ごとの命名規約には従うが、fieldの意味を
変えない。

| field | 必須 | 内容 |
| --- | --- | --- |
| `sourceUrl` | Yes | card tapで開くHTTP(S) URL |
| `title` | Yes | 1〜200文字のタイトル |
| `description` | No | 最大500文字の説明 |
| `siteName` | No | 最大100文字のサイト名 |
| `image` | No | appの画像loaderへ渡すopaqueなresourceと寸法 |

空title、HTTP(S)以外の`sourceUrl`、部分的に壊れたimageはpreview全体またはimageだけを
安全に非表示にする。モデルは保存schema version、Firestore path、bucket名を公開APIへ
持ち込まない。

送信済みmessageへ任意のpreviewを加える。既存initializerはpreview省略時に従来どおり
動作し、既存の`ChatMessageContent` caseを増やさない。Swift / Kotlinではmessageの任意
property、Flutterでは`ChatTextMessage`の任意propertyとして表現する。

## 入力中preview

- Room / Composerは任意の非同期resolverを受け取る。未指定時は取得も表示もしない。
- parserが先頭Web URLを検出してから500ミリ秒入力が変わらなければresolverを1回呼ぶ。
- 同じ正規化URLの再build・focus変更では再取得しない。
- URLが変わるか本文から消えた場合、表示中previewを消し、処理中の古い結果を採用しない。
- loading中はレイアウトを安定させるplaceholderを表示するが、send buttonを無効にしない。
- errorとpreviewなし結果は本文だけを表示し、利用者向けエラーを出さない。
- 取得済みdraft previewはsubmissionへ任意値として含め、appが送信中messageの楽観表示に
  使用できる。ただしbackendへ永続化する信頼済みmetadataとして扱わない。

既存送信callbackを破壊しない。Swift / Kotlinのsubmissionにはdefault `nil`の任意fieldを
加える。Flutterは既存record callbackを維持し、型付きsubmissionを受ける新callbackを追加する。
両callbackが指定された場合は新callbackだけを呼ぶ。

## メッセージ内カード

- 本文の下へ8pt相当の間隔を空けて配置し、本文の吹き出し幅を上限とする。
- サイト名、最大2行のtitle、最大3行のdescription、任意の代表画像を表示する。
- imageは縦横比を維持し、取得失敗時はmetadata領域を詰めて表示する。
- card全体を1つのlinkとして操作でき、本文リンクと同じ`sourceUrl`を開く。
- 選択、長押しmenu、reply、reaction、送信状態のhit targetを妨げない。
- 読み上げは「リンクプレビュー」、site name、title、description、URLの順にまとめる。
- loadingは入力中だけに表示し、送信済みmessageにはskeletonやerrorを残さない。

## 共通fixture

[`fixtures/link-preview-cases.json`](fixtures/link-preview-cases.json)を使い、少なくとも次を3platformで共有する。

- 先頭1件だけを選ぶ複数URL本文
- URL変更中のstale結果
- titleだけ、titleとdescription、titleとimage、全fieldあり
- 空title、不正scheme、未知schemaをappが除外したpreviewなし状態
- 長いCJK / 英語metadata、RTL、画像読み込み失敗

Preview / screenshot / goldenでは固定resolverとlocal fixture imageを使用し、外部networkへ
接続しない。

## 後方互換性

- previewは任意propertyとし、欠損messageを通常本文として表示する。
- 既存message initializer、Room initializer、送信callbackは維持する。
- resolverを接続しないconsumerの表示・送信・リンク遷移は変更しない。
- 新しいmessage propertyを追加しても`ChatMessageContent`の網羅的switchを壊さない。
- appからpreviewが渡されない限りcardを表示しない。

## 検証

- parser fixture、debounce、stale結果破棄、resolver未指定・失敗をunit testする。
- 送信をresolver完了まで待たないことと、submissionのdraft previewが任意であることをtestする。
- 3platformで全field、画像なし、画像失敗、長文、light / dark、文字拡大をvisual testする。
- card tapと本文linkが同じURLを通知し、長押し・reaction・replyと競合しないことをtestする。
- Flutter testで外部HTTP requestが発生しないことを保証する。

## 利用アプリへの導入

1. 使用するreleaseの表示modelとresolver契約を確認する。
2. 利用アプリの取得処理、保存済みmetadataのreader、画像loaderを接続する。
3. resolverなし・取得失敗・権限不足・未知データでも本文を表示・送信できることを確認する。
4. 対応versionまたはrevisionを固定し、利用アプリ側で統合を検証する。

製品固有のbackend配置、導入順、リリース承認は利用アプリ側で管理する。
