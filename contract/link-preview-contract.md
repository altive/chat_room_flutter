# Link preview contract

## 目的

テキストメッセージ本文の先頭Web URLを、送信前と送信後に共通のリンクプレビューとして
表示する。AltiveChatはFirebaseや外部サイトへ接続せず、利用アプリが検証した表示値と
画像loaderだけを受け取る。

プロダクト横断の取得、保存、安全要件はAltive Specsの
[`chat-link-preview.md`](https://github.com/altive/specs/blob/main/integrations/chat-link-preview.md)
を正本とし、本書は
AltiveChat内の公開モデルとUI契約だけを定義する。

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

- resolver callbackから認証済みbackendを呼ぶ処理
- Firebase Auth / App Check、scope所属、rate limit、SSRF対策
- OGP取得、cache、画像変換、Storage保存、Firestore永続化
- app固有schemaとAltiveChat表示モデルの変換
- Storage画像handleの解決と端末cache
- URLを開くnavigation方針と失敗処理

AltiveChatはHTTP client、HTML parser、Firebase SDK、product固有IDを依存へ追加しない。
Flutterに残る端末直接のOGP取得は新契約へ移行後に削除する。

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

`fixtures/link-preview-cases.json`を追加し、少なくとも次を3platformで共有する。

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
- Flutterの端末直接取得を削除した後は、appからpreviewが渡されない限りcardを表示しない。

## 検証

- parser fixture、debounce、stale結果破棄、resolver未指定・失敗をunit testする。
- 送信をresolver完了まで待たないことと、submissionのdraft previewが任意であることをtestする。
- 3platformで全field、画像なし、画像失敗、長文、light / dark、文字拡大をvisual testする。
- card tapと本文linkが同じURLを通知し、長押し・reaction・replyと競合しないことをtestする。
- Flutter testで外部HTTP requestが発生しないことを保証する。

## 展開

1. 任意model、resolver、fixture、UIを加算し、Flutterの直接取得はまだ利用しない経路へ移す。
2. Fanely / Nokorisのreaderと画像loaderを接続する。
3. consumer backendがpreviewを供給できる状態で対応versionをpinする。
4. Flutterの端末直接OGP実装と`html` / `http`依存を削除する。
