import Foundation

/// チャット画像の読み込み元。
public enum ChatImageResource: Hashable, Sendable {
  /// 送信中などに表示する端末内のファイル。
  case localFile(URL)

  /// アップロード後に表示するリモートファイル。
  case remote(URL)
}

/// 画像メッセージへ表示する1枚分の画像。
public struct ChatImage: Hashable, Identifiable, Sendable {
  /// 画像を一意に識別する値。
  public let id: String

  /// 画像の読み込み元。
  public let resource: ChatImageResource

  /// 元画像のピクセル幅。
  public let pixelWidth: Int?

  /// 元画像のピクセル高さ。
  public let pixelHeight: Int?

  /// VoiceOver向けの説明。
  public let accessibilityLabel: String?

  /// 画像メッセージへ表示する画像を作成する。
  public init(
    id: String,
    resource: ChatImageResource,
    pixelWidth: Int? = nil,
    pixelHeight: Int? = nil,
    accessibilityLabel: String? = nil
  ) {
    self.id = id
    self.resource = resource
    self.pixelWidth = pixelWidth
    self.pixelHeight = pixelHeight
    self.accessibilityLabel = accessibilityLabel
  }
}

/// 送信前の入力欄で保持する画像。
public struct ChatImageDraft: Hashable, Identifiable, Sendable {
  /// 画像を一意に識別する値。
  public let id: String

  /// アプリ側で正規化した一時ファイルのURL。
  public let fileURL: URL

  /// 正規化後のピクセル幅。
  public let pixelWidth: Int?

  /// 正規化後のピクセル高さ。
  public let pixelHeight: Int?

  /// VoiceOver向けの説明。
  public let accessibilityLabel: String?

  /// 送信前画像を作成する。
  public init(
    id: String,
    fileURL: URL,
    pixelWidth: Int? = nil,
    pixelHeight: Int? = nil,
    accessibilityLabel: String? = nil
  ) {
    self.id = id
    self.fileURL = fileURL
    self.pixelWidth = pixelWidth
    self.pixelHeight = pixelHeight
    self.accessibilityLabel = accessibilityLabel
  }

  /// 入力欄のプレビューに使用する画像へ変換する。
  public var previewImage: ChatImage {
    ChatImage(
      id: id,
      resource: .localFile(fileURL),
      pixelWidth: pixelWidth,
      pixelHeight: pixelHeight,
      accessibilityLabel: accessibilityLabel
    )
  }
}

/// テキストと画像をまとめた1回分の送信要求。
public struct ChatComposerSubmission: Hashable, Sendable {
  /// 正規化済みテキスト。画像だけを送る場合は `nil`。
  public let text: String?

  /// 選択順の送信画像。
  public let images: [ChatImageDraft]

  /// 入力中に解決済みだった任意のリンクプレビュー。
  ///
  /// アプリ側は楽観表示にだけ使用し、永続化時はbackendの検証結果を使用する。
  public let linkPreview: ChatLinkPreview?

  /// 正規化済みテキストと画像から送信要求を作成する。
  ///
  /// 両方が空の場合は `nil` を返す。
  public init?(
    text: String?,
    images: [ChatImageDraft],
    linkPreview: ChatLinkPreview? = nil
  ) {
    let normalizedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
    let nonemptyText = normalizedText.flatMap { $0.isEmpty ? nil : $0 }
    guard nonemptyText != nil || !images.isEmpty else { return nil }
    self.text = nonemptyText
    self.images = images
    self.linkPreview = nonemptyText == nil ? nil : linkPreview
  }

  /// 入力方針を適用した送信要求を作成する。
  public init?(
    draft: String,
    images: [ChatImageDraft],
    policy: ChatDraftPolicy,
    linkPreview: ChatLinkPreview? = nil
  ) {
    let text = policy.normalizedText(from: draft)
    guard text != nil || !images.isEmpty else { return nil }
    self.text = text
    self.images = images
    self.linkPreview = text == nil ? nil : linkPreview
  }
}
