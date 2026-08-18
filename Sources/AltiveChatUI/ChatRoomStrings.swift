import Foundation

/// チャット画面で使用する文言。
public struct ChatRoomStrings: Equatable, Sendable {
  /// メッセージが存在しない場合の文言。
  public var emptyMessage: String

  /// 入力欄のプレースホルダー。
  public var messagePlaceholder: String

  /// 送信ボタンのアクセシビリティラベル。
  public var sendButtonLabel: String

  /// 送信中状態の文言。
  public var sendingLabel: String

  /// 送信失敗状態の文言。
  public var failedLabel: String

  /// 送信者が不明な場合の表示名。
  public var unknownSender: String

  /// カメラボタンのアクセシビリティラベル。
  public var cameraButtonLabel: String

  /// 写真ライブラリボタンのアクセシビリティラベル。
  public var photoLibraryButtonLabel: String

  /// 添付ボタン群を展開するボタンのアクセシビリティラベル。
  public var expandSourceButtonsLabel: String

  /// 選択画像を削除するボタンのアクセシビリティラベル。
  public var removeImageButtonLabel: String

  /// 画像の代替ラベル。
  public var imageLabel: String

  /// 画像の読み込み失敗を示す文言。
  public var imageLoadingFailedLabel: String

  /// チャット画面で使用する文言を作成する。
  public init(
    emptyMessage: String,
    messagePlaceholder: String,
    sendButtonLabel: String,
    sendingLabel: String,
    failedLabel: String,
    unknownSender: String,
    cameraButtonLabel: String = "Camera",
    photoLibraryButtonLabel: String = "Photo library",
    expandSourceButtonsLabel: String = "Show attachment buttons",
    removeImageButtonLabel: String = "Remove image",
    imageLabel: String = "Image",
    imageLoadingFailedLabel: String = "Failed to load image"
  ) {
    self.emptyMessage = emptyMessage
    self.messagePlaceholder = messagePlaceholder
    self.sendButtonLabel = sendButtonLabel
    self.sendingLabel = sendingLabel
    self.failedLabel = failedLabel
    self.unknownSender = unknownSender
    self.cameraButtonLabel = cameraButtonLabel
    self.photoLibraryButtonLabel = photoLibraryButtonLabel
    self.expandSourceButtonsLabel = expandSourceButtonsLabel
    self.removeImageButtonLabel = removeImageButtonLabel
    self.imageLabel = imageLabel
    self.imageLoadingFailedLabel = imageLoadingFailedLabel
  }

  /// Package内のローカライズ済み文言。
  public static var localized: Self {
    .init(
      emptyMessage: String(localized: "chat.empty", bundle: .module),
      messagePlaceholder: String(localized: "chat.composer.placeholder", bundle: .module),
      sendButtonLabel: String(localized: "chat.composer.send", bundle: .module),
      sendingLabel: String(localized: "chat.delivery.sending", bundle: .module),
      failedLabel: String(localized: "chat.delivery.failed", bundle: .module),
      unknownSender: String(localized: "chat.sender.unknown", bundle: .module),
      cameraButtonLabel: String(localized: "chat.composer.camera", bundle: .module),
      photoLibraryButtonLabel: String(localized: "chat.composer.photoLibrary", bundle: .module),
      expandSourceButtonsLabel: String(
        localized: "chat.composer.expandSourceButtons",
        bundle: .module
      ),
      removeImageButtonLabel: String(localized: "chat.composer.removeImage", bundle: .module),
      imageLabel: String(localized: "chat.image.label", bundle: .module),
      imageLoadingFailedLabel: String(localized: "chat.image.loadingFailed", bundle: .module)
    )
  }
}
