# Jetpack Compose 画像メッセージ実装仕様

## 概要

Compose版はSwiftUI版と同じく、カメラ・写真ボタン、複数画像プレビュー、既定4枚の
選択上限、テキストと画像の同時送信、複数画像メッセージを提供する。

`chat-core`はAndroid frameworkへ依存せず、URIを文字列として保持する。
`chat-ui-compose`がPhoto Pickerと一時的な選択状態を所有し、画像加工と外部I/Oは
アプリ側へ残す。

## Photo Picker

`ChatPhotoLibraryPresentationStyle.System`は
`PickVisualMedia`／`PickMultipleVisualMedia`を使用する。Photo Picker非対応端末では
AndroidX Activityが`ACTION_OPEN_DOCUMENT`等へフォールバックする。フォールバック先では
OSが複数選択上限を無視する場合があるため、AltiveChat側でも結果を上限以内へ丸める。

`ChatPhotoLibraryPresentationStyle.Inline`はAndroidX
`EmbeddedPhotoPicker`を使用する。利用条件はAndroid 14（API 34）かつSDK Extensions 15以上。
条件を満たさない端末ではSystem表示へフォールバックする。

Embedded Picker上部のPackage所有ハンドルだけへ縦ドラッグを設定する。写真グリッド本体の
スクロールとは競合させない。compact高は利用可能高の36%、expanded高は約78%を基準にする。

AndroidX `photopicker-compose`は現時点で`1.0.0-alpha02`のため、更新時はAPI差分と
対応SDK Extensionsを確認する。

## 公開契約

- `ChatImageInputConfiguration`の既定上限は4枚で、1以上を要求する。
- `resolvePhotoLibraryUri`はPickerが返したURI文字列を、アプリ管理の
  `ChatImageDraft`へ非同期変換する。
- カメラは`onRequestCamera`だけを通知する。結果はアプリが`imageDrafts`へ追加する。
- `onSubmit`は正規化済みテキストと全画像を1つの`ChatComposerSubmission`として返す。
- `imageContent`はCoil等を使うアプリ側のComposableを受け取る。認証、キャッシュ、
  読み込み中／失敗表示もこのrendererが所有する。
- `onImageTap`はメッセージIDと画像indexを返し、画面遷移は行わない。

## 表示

- 1枚は縦横比を反映した上限付き表示。
- 2枚は2列。
- 3枚は先頭を大きく、残り2枚を右へ配置。
- 4枚は2×2。
- 5枚以上は先頭4枚を表示し、4枚目へ`+N`を重ねる。
- 送信中／失敗／再送は既存の`ChatDeliveryIndicator`を利用する。

## 後方互換

既存のテキスト専用`AltiveChatRoom(..., onSend)`は維持し、画像ボタンを表示しない。
画像対応は`imageDrafts`と`onSubmit`を持つoverloadを使った場合だけ有効になる。
`ChatMessageContent.Images`追加により、利用アプリの網羅的`when`はcase追加が必要になる。
