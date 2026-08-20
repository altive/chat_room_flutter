# 汎用メッセージカード契約

## Status

本書はtarget designであり、`ChatMessageCard`は未実装である。公開API、theme、layout、
accessibility、visual test、release条件まで確定しており、Flutter、SwiftUI、
Jetpack Composeの実装着手が可能な状態とする。3実装とtestが揃ってから`implemented`へ変更する。

## 目的

送信者を持つメッセージを、通常の吹き出しより強く視覚表現するための汎用カードを
提供する。誕生日、記念日、感謝、季節イベントなどの業務上の意味は利用アプリに残し、
AltiveChatは表示とアクセシビリティだけを共有する。

## 責務境界

AltiveChatが所有する。

- カードの角丸、境界線、背景、標準padding、slot間隔。
- 自分・相手のメッセージalignmentに馴染む外観。
- styleに応じた静的な背景装飾。
- Dynamic Type / font scale、Dark Mode、RTL、Reduce Motionへの追従。
- カード全体のアクセシビリティcontainer。
- Flutter、SwiftUI、Composeで意味を揃えたPreview / visual test fixture。

利用アプリが所有する。

- Firestoreなどの永続化schemaとmessage kind。
- birthdayなどのカード用途、宛先、権限、送信、削除、非表示、再送。
- 保存済みkind / design IDから`ChatMessageCardStyle`への変換。
- header、content、footerへ渡すローカライズ済み表示内容。
- 投稿者名、アバター、時刻、リアクション、長押しmenuの外側layout。
- 未知・破損payloadの通常テキストfallback。

AltiveChatはFirebase SDK、アプリ固有ID、金額、ポイント、誕生日などのDomain型へ依存しない。

## 公開API

### 共通の意味

| 入力 | 必須 | 責務 |
| --- | --- | --- |
| `style` | Yes | ライブラリが管理する意味的な外観 |
| `isOwnMessage` | Yes | 送信側・受信側のalignmentとshape調整 |
| `theme` | No | platform標準の`ChatRoomTheme`。未指定は標準theme |
| `accessibilityLabel` | Yes | カード用途を説明するローカライズ済みlabel |
| `header` | Yes | 見出しや宛名を表示するslot |
| `content` | Yes | 本文を表示するslot |
| `footer` | No | 補足やアプリ所有の表示を置くslot |

初期styleは`celebration`だけとする。`birthday`はアプリ固有の用途なのでstyle名には使わない。
style追加は後方互換な公開API追加として扱い、各platformへ同時に追加する。

### SwiftUI

```swift
ChatMessageCard(
  style: .celebration,
  isOwnMessage: isOwnMessage,
  theme: .fanely,
  accessibilityLabel: accessibilityLabel
) {
  header
} content: {
  content
} footer: {
  footer
}
```

`ChatMessageCardStyle`と`ChatMessageCard`は`AltiveChatUI`に置く。表示専用styleを
`AltiveChatCore`へ置かない。footer未指定initializerは`EmptyView`を使用する。

### Jetpack Compose

```kotlin
ChatMessageCard(
  style = ChatMessageCardStyle.Celebration,
  isOwnMessage = isOwnMessage,
  theme = ChatRoomTheme.fanely(),
  accessibilityLabel = accessibilityLabel,
  header = { header() },
  content = { content() },
  footer = { footer() },
)
```

`ChatMessageCardStyle`とComposableは`chat-ui-compose`に置く。footerの既定値は空の
Composableとする。

### Flutter

```dart
ChatMessageCard(
  style: ChatMessageCardStyle.celebration,
  isOwnMessage: isOwnMessage,
  theme: const AltiveChatRoomTheme(),
  accessibilityLabel: accessibilityLabel,
  header: header,
  content: content,
  footer: footer,
)
```

`ChatMessageCardStyle`とWidgetはFlutter packageのpresentation層へ置く。footerは
nullableとする。

## Celebration style

- 角丸は20、境界線は1、内側paddingは16を基準とする。
- header、content、footerの縦間隔は順に8、12を基準とする。
- 背景は暖色系の低彩度gradient、境界線はaccentの半透明色とする。
- 紙吹雪を想起する静的装飾を背景へ置き、読み上げ対象から除外する。
- 自動再生、無限animation、触覚、音は含めない。
- `isOwnMessage`は外側alignmentとshapeの向きにだけ使い、本文のcontrastを変えない。
- 文字色は背景に対してWCAG AAを満たすtheme tokenを使用する。
- 装飾が非表示でもheaderとaccessibility labelだけでカード用途を理解できるようにする。

配色は各platformのsemantic colorから組み立て、Dark ModeとHigh Contrastで再計算する。
固定RGB値の完全一致より、contrastと意味の一致を優先する。

## Theme拡張

既存のthemeへ次の意味的tokenを後方互換なdefault付きで追加する。

| token | 用途 |
| --- | --- |
| `celebrationCardBackgroundStart` | gradient開始色 |
| `celebrationCardBackgroundEnd` | gradient終了色 |
| `celebrationCardBorder` | 1pt / 1dp相当の境界線 |
| `celebrationCardForeground` | headerと本文の既定文字色 |
| `celebrationCardAccent` | 紙吹雪などの装飾色 |

SwiftUI / Compose / Flutterで同じtoken名と意味を使用する。既存consumerのtheme初期化を
壊さないよう、SwiftとFlutterはinitializer default、Composeはdata class defaultを持つ。

## Layoutと操作

- component自身は最大幅を固定せず、利用側のタイムラインが既存message幅を適用する。
- 長文では縦方向へ伸長し、headerとcontentをtruncationしない。
- RTLではslot内容と装飾方向をmirrorする。
- component自身はtap、long press、navigationを所有しない。既存のmessage menuや
  reaction containerが外側からgestureを付与する。
- 送信取消・非表示済みでは利用アプリがtombstoneを表示し、カードを構築しない。
- footerにactionを置く場合、実行可否と最小tap targetは利用アプリが保証する。

## アクセシビリティ

- カード全体を1つの意味的groupとして扱い、`accessibilityLabel`を先に読み上げる。
- header、content、footerの文字は通常の読み上げ順を維持する。
- 背景装飾と紙吹雪は読み上げとfocus対象から除外する。
- 色、gradient、左右配置だけをカード識別や送信者識別の唯一の手段にしない。
- Reduce Motionの有無にかかわらず同じ情報を提供する。

## 利用アプリとのmapping

利用アプリの保存契約例が`messageKind = card`、`card.kind = birthday`であっても、
AltiveChatはそれらの文字列を解釈しない。利用アプリがpayloadを検証し、次のように
presentationへ変換する。

```text
card.kind=birthday + supported design ID
  -> ChatMessageCardStyle.celebration

unknown kind / unsupported schema / broken payload
  -> 通常テキストfallback。ChatMessageCardは構築しない
```

## Test契約

各platformで最低限、次を固定fixtureとして検証する。

- 自分・相手の配置。
- footerあり・なし。
- 短文と複数行の長文。
- 最小対応幅と通常幅。
- Light / Dark ModeとHigh Contrast。
- 最大accessibility text sizeまたは同等のfont scale。
- RTL locale。
- accessibility treeから装飾が除外されること。
- 既存のmessage bubble、system event、reaction、long press UIに退行がないこと。

SwiftUIはSnapshot、ComposeはPreview screenshot、Flutterはgolden testを使用する。
baselineは意図した表示を目視確認した場合だけ更新する。

## Release条件

- Flutter、SwiftUI、Composeの公開APIとtestが同一releaseで揃う。
- SemVer minorとしてreleaseし、利用アプリが依存revision / versionを明示更新する。
- FanelyとNokorisの利用箇所を確認し、非該当platformも既存チャットの回帰testを行う。
- 利用アプリの永続化やbackend変更をAltiveChat releaseへ含めない。
