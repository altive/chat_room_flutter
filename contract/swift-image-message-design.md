# SwiftUI 画像メッセージ設計

## 目的

SwiftUI版のチャット入力欄で、テキストフィールドの左にカメラと写真ライブラリの
ボタンを表示し、取得した画像を確認して送信できるようにする。また、送信中、送信済み、
送信失敗の画像メッセージをテキストメッセージと同じタイムラインへ表示する。

本設計では、チャットUIの再利用性を保つため、画像取得と外部I/Oを分離する。
`AltiveChatUI`は画像取得を要求する操作をアプリへ通知するが、Picker、権限、画像加工、
アップロード、永続化は所有しない。

## 対象範囲

最初のリリースでは次を対象とする。

- カメラ、写真ライブラリの2ボタン
- 1回の操作で1画像を選択または撮影
- 選択画像のプレビュー、取り消し、送信
- ローカル一時ファイルを使った楽観的な画像メッセージ表示
- リモート画像メッセージの表示、読み込み中、読み込み失敗
- 画像タップのコールバック
- 既存の送信中、送信失敗、再送UIとの統合

Coreの型は将来の複数画像送信に備えて配列を採用する。ただし、最初のUIとアプリ連携は
1画像に制限し、複数画像のグリッド、並び替え、部分的なアップロード失敗は後続とする。
動画、Live Photos、画像編集、キャプション、全画面ビューアも初回の対象外とする。

## 責務の境界

| AltiveChatが所有する | アプリが所有する |
| --- | --- |
| カメラ・写真ボタンの配置、見た目、アクセシビリティ | `PhotosPicker`、カメラ画面の表示とdismiss |
| 画像取得元を通知する操作契約 | カメラ利用可否と権限状態の判定 |
| 選択済み画像のプレビュー、削除、送信導線 | `PhotosPickerItem`や撮影結果の読み出し |
| 画像メッセージのレイアウト | EXIF orientationの正規化、縮小、圧縮、形式変換 |
| ローカル／リモート画像の読み込み状態表示 | Packageが読める一時ファイルの作成と寿命管理 |
| 送信中・失敗表示、再送操作の通知 | Storageへのアップロード、Firestore等への永続化 |
| 画像タップ時のメッセージIDと位置の通知 | 全画面ビューアや画面遷移 |
| 標準URLローダーと差し替え可能な読み込み契約 | 認証付き取得、キャッシュ、再試行方針 |

Packageは`PhotosUI`、`AVFoundation`、Firebase SDK、アプリのStoreへ依存しない。
特にカメラ権限はホストアプリの`Info.plist`と画面遷移に関係するため、アプリ側に残す。

## 値モデル

### 画像取得元

`AltiveChatUI`に、ボタン操作を表す値だけを追加する。

```swift
public enum ChatImageInputSource: Hashable, Identifiable, Sendable {
  case camera
  case photoLibrary

  public var id: Self { self }
}
```

アプリは`onRequestImageInput`を受け、対応するPickerを表示する。コールバックが`nil`の
場合は両方のボタンを表示しない。カメラを利用できない端末などでは、
`availableImageInputSources`から`.camera`を除外する。

### 選択中の画像

Picker固有型や`UIImage`を公開契約へ含めず、アプリが一時ファイルへ正規化した後の値を
`AltiveChatCore`へ渡す。

```swift
public struct ChatImageDraft: Hashable, Identifiable, Sendable {
  public let id: String
  public let fileURL: URL
  public let pixelWidth: Int?
  public let pixelHeight: Int?
  public let accessibilityLabel: String?
}
```

`fileURL`はPackageから読み取れるローカルファイルURLに限定する。アプリは選択開始時に
処理中状態を表示し、Pickerが返したデータをアプリ管理の一時領域へコピーしてから
`imageDrafts` Bindingを更新する。セキュリティスコープやPhotos Pickerの一時URLを
そのまま長期保持しない。アプリは送信成功、送信の明示的な破棄、または再送不要の確定まで
一時ファイルを保持し、その後に削除する。

### 表示する画像

送信中はローカル一時ファイル、送信確定後はリモートURLを表示できるようにする。

```swift
public enum ChatImageResource: Hashable, Sendable {
  case localFile(URL)
  case remote(URL)
}

public struct ChatImage: Hashable, Identifiable, Sendable {
  public let id: String
  public let resource: ChatImageResource
  public let pixelWidth: Int?
  public let pixelHeight: Int?
  public let accessibilityLabel: String?
}

public enum ChatMessageContent: Hashable, Sendable {
  case text(String)
  case images([ChatImage])
  case system(String)
}
```

`.images`は1件以上を前提とする。初回は先頭の1件のみを入力できるが、配列を契約にする
ことでFlutter版の`ChatImagesMessage`と将来揃えられる。送信前後でメッセージIDと
画像IDを維持し、アプリが`resource`と`deliveryState`を差し替える。

## AltiveChatUIの公開API案

既存のテキスト専用initializerは維持する。画像機能を使う場合だけ、次の引数を指定する。

```swift
AltiveChatRoom(
  messages: messages,
  currentUserID: currentUserID,
  draft: $draft,
  imageDrafts: $imageDrafts,
  availableImageInputSources: [.camera, .photoLibrary],
  isPreparingImage: isPreparingImage,
  imageLoader: imageLoader,
  onRequestImageInput: { source in
    presentedImagePicker = source
  },
  onImageTap: { messageID, imageIndex in
    // アプリの画像ビューアを表示
  },
  onSendImages: { drafts in
    chatStore.sendImages(drafts)
  },
  onRetry: chatStore.retry,
  onSend: chatStore.sendText
)
```

追加する入力は次のとおりとする。

```swift
imageDrafts: Binding<[ChatImageDraft]> = .constant([])
availableImageInputSources: Set<ChatImageInputSource> = []
isPreparingImage: Bool = false
imageLoader: ChatImageLoader = .urlSession
onRequestImageInput: ((ChatImageInputSource) -> Void)? = nil
onImageTap: ((_ messageID: String, _ imageIndex: Int) -> Void)? = nil
onSendImages: (([ChatImageDraft]) -> Void)? = nil
```

`ChatImageLoader`は画像resourceからデータを非同期取得する軽量なclosure clientとする。

```swift
public struct ChatImageLoader: Sendable {
  public var load: @Sendable (ChatImageResource) async throws -> Data
}
```

標準実装はローカルファイルと通常のHTTP(S) URLを読み込む。認証ヘッダーや独自キャッシュが
必要なアプリは差し替える。ロード結果のデコード、プレースホルダー、失敗表示はUI側が
担当し、キャンセルは通常終了として扱う。

## Composerの振る舞い

1. テキストフィールドの左に、SF Symbolsの`camera`と`photo`を使う44pt以上のタップ領域を置く。
2. `availableImageInputSources`に含まれるボタンだけを表示する。
3. ボタン押下時はキーボードを閉じ、`onRequestImageInput`へ取得元を通知する。
4. `isPreparingImage`中は両ボタンを無効化し、入力欄の左側に`ProgressView`を表示する。
5. `imageDrafts`が更新されたら、既存の添付プレビュー領域へサムネイルと削除ボタンを表示する。
6. 画像選択中はテキストフィールドを無効化し、送信ボタンは画像送信に切り替える。既存の
   テキスト下書きは消さず、画像の送信または削除後に再び編集可能にする。
7. 画像送信時は`onSendImages`へ現在のスナップショットを渡してからBindingを空にする。
8. アプリはコールバック内で安定したIDの`.sending`メッセージを即座に追加する。

初回はテキストと画像を同一メッセージとして送らない。画像選択前のテキスト下書きを保持する
ことで、暗黙に2種類のメッセージを同時送信して部分失敗する状態を避ける。
ボタン順は`Set`の列挙順に依存させず、常にカメラ、写真ライブラリの順とする。

## タイムラインの振る舞い

- 画像は縦横比を尊重し、極端な比率でも最大幅と最大高を超えないようにする。
- 送信中のローカル画像にもリモート画像と同じレイアウトを適用し、切り替え時の跳ねを抑える。
- 読み込み中は画像領域と同じ比率のプレースホルダーを出す。
- 読み込み失敗は画像領域内に再読み込み可能な失敗表示を出す。メッセージ送信失敗の
  `ChatDeliveryIndicator`とは意味を分ける。
- 送信中は既存の`ChatDeliveryIndicator`を表示する。
- 送信失敗時はローカル画像を保持したまま既存の再送操作を通知する。
- 画像タップ時は`messageID`と配列indexをアプリへ返す。Packageは画面遷移を行わない。
- VoiceOverでは`accessibilityLabel`を優先し、未指定時はローカライズした「画像」を使う。
- カメラ、写真ライブラリ、画像削除、画像送信、画像読み込み失敗にもPackage内の
  ローカライズ済みアクセシビリティ文言を用意する。

## アプリ側の処理フロー

```text
ボタン操作
  -> onRequestImageInput(.camera / .photoLibrary)
  -> アプリが権限確認とPicker表示
  -> 取得結果を向き補正・縮小・圧縮
  -> アプリ管理の一時ファイルへ保存
  -> imageDrafts Bindingへ反映
  -> ユーザーが送信
  -> onSendImages
  -> ローカルURLを持つ sending メッセージを即時追加
  -> Storageへアップロード
  -> 成功: 同じIDのremote URL + sentへ更新
  -> 失敗: ローカルURLを維持してfailedへ更新
```

キャンセル時はBindingを変更しない。読み出し、加工、保存に失敗した場合はアプリがAlertや
Toastを表示する。カメラ権限が拒否済みの場合の設定画面誘導もアプリが担当する。

写真ライブラリにはSwiftUIの`PhotosPicker`を使用する。選択結果はプレースホルダーであり、
iCloud上の画像読み込みが失敗する可能性があるため、`loadTransferable`の処理中、失敗、
キャンセルを区別する。カメラにはシステムのカメラUIを使用し、利用前にカメラの存在と
権限を確認する。ホストアプリは`NSCameraUsageDescription`を設定する。

## 後方互換

- `ChatMessageContent`へのcase追加は既存アプリの網羅的`switch`でコンパイルエラーを起こし得る。
  SemVer上はminor追加でも、利用アプリの移行を先に確認してからリリースする。
- `AltiveChatRoom`の既存initializerは残し、画像関連引数は既定値で無効にする。
- 画像ボタンは`onRequestImageInput == nil`または取得元が空の場合に表示しないため、既存画面の
  見た目と余白は変わらない。
- Flutterの公開APIは変更しない。SwiftUI実装後にfeature matrixだけを`implemented`へ更新する。

## 実装順序

1. `AltiveChatCore`へ画像値モデルと単体テストを追加する。
2. 画像ローダー、単一画像バブル、読み込み状態、画像タップを`AltiveChatUI`へ追加する。
3. `ChatComposer`へ先頭アクション領域と画像ドラフトの状態遷移を追加する。
4. `AltiveChatRoom`から画像APIを公開し、Previewとアクセシビリティ文言を追加する。
5. Swift Packageの単体テスト、iOS build、Family Room相当の画面確認を行う。
6. 利用アプリでPicker、権限、一時ファイル、アップロード、永続化を接続する。

## テスト観点

- 画像機能を指定しない既存initializerでボタンが表示されない。
- 利用可能な取得元に応じて各ボタンが表示され、正しい値をコールバックする。
- 処理中は多重起動と送信ができない。
- 選択、削除、送信後のBindingとテキスト下書きが仕様どおり変化する。
- 空の画像配列を送信しない。
- local、remote、縦長、横長、読み込み中、読み込み失敗を表示できる。
- 送信中、送信失敗、再送操作が画像メッセージでも機能する。
- 画像タップが正しいメッセージIDとindexを返す。
- Dynamic Type、VoiceOver、ダークモードで操作と表示が破綻しない。
- Pickerキャンセル、iCloud取得失敗、権限拒否、アップロード失敗後に復帰できる。

## 参照するApple API

- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [UIImagePickerController](https://developer.apple.com/documentation/uikit/uiimagepickercontroller)
- [Requesting authorization to capture and save media](https://developer.apple.com/documentation/avfoundation/requesting-authorization-to-capture-and-save-media)
