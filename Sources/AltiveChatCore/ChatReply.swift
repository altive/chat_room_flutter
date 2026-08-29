import Foundation

/// 返信元を再取得せずに引用表示するための軽量な内容。
public enum ChatReplyPreviewContent: Hashable, Sendable {
  /// テキスト本文。
  case text(String)

  /// 画像と任意のcaption。`totalCount`は元メッセージの画像数。
  case image(thumbnail: ChatImage?, caption: String?, totalCount: Int)

  /// 構造化されたステッカー参照。
  case sticker(ChatStickerReference)

  /// 汎用カードなどを表す短い文言。
  case label(String)

  /// 削除・非表示などにより内容を表示できない状態。
  case unavailable
}

/// 返信元の非再帰snapshot。
public struct ChatReplyReference: Hashable, Sendable {
  /// 返信元の安定したメッセージID。
  public let messageID: String

  /// 返信元の送信者ID。
  public let senderID: String

  /// 返信元の送信者表示名。
  public let senderDisplayName: String

  /// 引用表示する内容。
  public let content: ChatReplyPreviewContent

  /// 複数画像の特定画像へ返信する場合のindex。
  public let imageIndex: Int?

  /// 軽量な返信参照を作成する。
  public init(
    messageID: String,
    senderID: String,
    senderDisplayName: String,
    content: ChatReplyPreviewContent,
    imageIndex: Int? = nil
  ) {
    self.messageID = messageID
    self.senderID = senderID
    self.senderDisplayName = senderDisplayName
    self.content = content
    self.imageIndex = imageIndex
  }

  /// 送信済みの標準メッセージから返信参照を作成する。
  public init?(message: ChatMessage, imageIndex: Int? = nil) {
    guard message.deliveryState == .sent, let sender = message.sender else { return nil }

    let preview: ChatReplyPreviewContent
    let normalizedImageIndex: Int?
    switch message.content {
    case .text(let text):
      preview = .text(text)
      normalizedImageIndex = nil
    case .images(let images):
      guard let selection = Self.imageSelection(images: images, requestedIndex: imageIndex) else {
        return nil
      }
      preview = .image(thumbnail: selection.image, caption: nil, totalCount: images.count)
      normalizedImageIndex = selection.index
    case .imagesWithCaption(let images, let caption):
      guard let selection = Self.imageSelection(images: images, requestedIndex: imageIndex) else {
        return nil
      }
      preview = .image(
        thumbnail: selection.image,
        caption: caption,
        totalCount: images.count
      )
      normalizedImageIndex = selection.index
    case .sticker(let reference):
      preview = .sticker(reference)
      normalizedImageIndex = nil
    case .system:
      return nil
    }

    self.init(
      messageID: message.id,
      senderID: sender.id,
      senderDisplayName: sender.displayName,
      content: preview,
      imageIndex: normalizedImageIndex
    )
  }

  private static func imageSelection(
    images: [ChatImage],
    requestedIndex: Int?
  ) -> (image: ChatImage, index: Int?)? {
    guard let first = images.first else { return nil }
    guard let requestedIndex, images.indices.contains(requestedIndex) else {
      return (first, nil)
    }
    return (images[requestedIndex], requestedIndex)
  }
}
