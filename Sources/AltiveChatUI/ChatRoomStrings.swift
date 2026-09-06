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

  /// 画像取得元メニューボタンのアクセシビリティラベル。
  public var imageSourceMenuLabel: String

  /// ファイル選択操作の文言。
  public var fileButtonLabel: String

  /// クリップボードから追加する操作の文言。
  public var clipboardButtonLabel: String

  /// 添付ボタン群を展開するボタンのアクセシビリティラベル。
  public var expandSourceButtonsLabel: String

  /// 選択画像を削除するボタンのアクセシビリティラベル。
  public var removeImageButtonLabel: String

  /// 画像の代替ラベル。
  public var imageLabel: String

  /// 画像の読み込み失敗を示す文言。
  public var imageLoadingFailedLabel: String

  /// ステッカーの代替ラベル。
  public var stickerLabel: String

  /// ステッカーの読み込み失敗を示す文言。
  public var stickerLoadingFailedLabel: String

  /// 最新メッセージへ移動するボタンの文言。
  public var latestMessagesLabel: String

  /// 電話番号をタップした際の選択肢タイトル。
  public var phoneActionTitle: String

  /// 電話をかける操作の文言。
  public var callActionLabel: String

  /// SMSを送信する操作の文言。
  public var messageActionLabel: String

  /// 電話番号の操作をキャンセルする文言。
  public var cancelActionLabel: String

  /// リンクプレビューのアクセシビリティラベル。
  public var linkPreviewLabel: String

  /// 入力中リンクプレビューの読み込み中を示す文言。
  public var linkPreviewLoadingLabel: String

  /// 返信actionの文言。
  public var replyActionLabel: String

  /// 返信選択を取り消す文言。
  public var cancelReplyLabel: String

  /// 引用の読み上げ接頭辞。
  public var replyToLabel: String

  /// 内容を表示できない返信元の文言。
  public var replyUnavailableLabel: String

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
    imageSourceMenuLabel: String = "Add image",
    fileButtonLabel: String = "Files",
    clipboardButtonLabel: String = "Clipboard",
    expandSourceButtonsLabel: String = "Show attachment buttons",
    removeImageButtonLabel: String = "Remove image",
    imageLabel: String = "Image",
    imageLoadingFailedLabel: String = "Failed to load image",
    stickerLabel: String = "Sticker",
    stickerLoadingFailedLabel: String = "Failed to load sticker",
    latestMessagesLabel: String = "Latest messages",
    phoneActionTitle: String = "Choose an action",
    callActionLabel: String = "Call",
    messageActionLabel: String = "Send message",
    cancelActionLabel: String = "Cancel",
    linkPreviewLabel: String = "Link preview",
    linkPreviewLoadingLabel: String = "Loading link preview",
    replyActionLabel: String = "Reply",
    cancelReplyLabel: String = "Cancel reply",
    replyToLabel: String = "Replying to",
    replyUnavailableLabel: String = "This message is unavailable"
  ) {
    self.emptyMessage = emptyMessage
    self.messagePlaceholder = messagePlaceholder
    self.sendButtonLabel = sendButtonLabel
    self.sendingLabel = sendingLabel
    self.failedLabel = failedLabel
    self.unknownSender = unknownSender
    self.cameraButtonLabel = cameraButtonLabel
    self.photoLibraryButtonLabel = photoLibraryButtonLabel
    self.imageSourceMenuLabel = imageSourceMenuLabel
    self.fileButtonLabel = fileButtonLabel
    self.clipboardButtonLabel = clipboardButtonLabel
    self.expandSourceButtonsLabel = expandSourceButtonsLabel
    self.removeImageButtonLabel = removeImageButtonLabel
    self.imageLabel = imageLabel
    self.imageLoadingFailedLabel = imageLoadingFailedLabel
    self.stickerLabel = stickerLabel
    self.stickerLoadingFailedLabel = stickerLoadingFailedLabel
    self.latestMessagesLabel = latestMessagesLabel
    self.phoneActionTitle = phoneActionTitle
    self.callActionLabel = callActionLabel
    self.messageActionLabel = messageActionLabel
    self.cancelActionLabel = cancelActionLabel
    self.linkPreviewLabel = linkPreviewLabel
    self.linkPreviewLoadingLabel = linkPreviewLoadingLabel
    self.replyActionLabel = replyActionLabel
    self.cancelReplyLabel = cancelReplyLabel
    self.replyToLabel = replyToLabel
    self.replyUnavailableLabel = replyUnavailableLabel
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
      imageSourceMenuLabel: String(localized: "chat.composer.imageSourceMenu", bundle: .module),
      fileButtonLabel: String(localized: "chat.composer.file", bundle: .module),
      clipboardButtonLabel: String(localized: "chat.composer.clipboard", bundle: .module),
      expandSourceButtonsLabel: String(
        localized: "chat.composer.expandSourceButtons",
        bundle: .module
      ),
      removeImageButtonLabel: String(localized: "chat.composer.removeImage", bundle: .module),
      imageLabel: String(localized: "chat.image.label", bundle: .module),
      imageLoadingFailedLabel: String(localized: "chat.image.loadingFailed", bundle: .module),
      stickerLabel: String(localized: "chat.sticker.label", bundle: .module),
      stickerLoadingFailedLabel: String(
        localized: "chat.sticker.loadingFailed",
        bundle: .module
      ),
      latestMessagesLabel: String(localized: "chat.timeline.latest", bundle: .module),
      phoneActionTitle: String(localized: "chat.link.phone.title", bundle: .module),
      callActionLabel: String(localized: "chat.link.phone.call", bundle: .module),
      messageActionLabel: String(localized: "chat.link.phone.message", bundle: .module),
      cancelActionLabel: String(localized: "chat.link.phone.cancel", bundle: .module),
      linkPreviewLabel: String(localized: "chat.linkPreview.label", bundle: .module),
      linkPreviewLoadingLabel: String(
        localized: "chat.linkPreview.loading",
        bundle: .module
      ),
      replyActionLabel: String(localized: "chat.reply.action", bundle: .module),
      cancelReplyLabel: String(localized: "chat.reply.cancel", bundle: .module),
      replyToLabel: String(localized: "chat.reply.to", bundle: .module),
      replyUnavailableLabel: String(localized: "chat.reply.unavailable", bundle: .module)
    )
  }
}
