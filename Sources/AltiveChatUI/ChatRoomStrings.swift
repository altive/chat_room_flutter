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

  /// チャット画面で使用する文言を作成する。
  public init(
    emptyMessage: String,
    messagePlaceholder: String,
    sendButtonLabel: String,
    sendingLabel: String,
    failedLabel: String,
    unknownSender: String
  ) {
    self.emptyMessage = emptyMessage
    self.messagePlaceholder = messagePlaceholder
    self.sendButtonLabel = sendButtonLabel
    self.sendingLabel = sendingLabel
    self.failedLabel = failedLabel
    self.unknownSender = unknownSender
  }

  /// Package内のローカライズ済み文言。
  public static var localized: Self {
    .init(
      emptyMessage: String(localized: "chat.empty", bundle: .module),
      messagePlaceholder: String(localized: "chat.composer.placeholder", bundle: .module),
      sendButtonLabel: String(localized: "chat.composer.send", bundle: .module),
      sendingLabel: String(localized: "chat.delivery.sending", bundle: .module),
      failedLabel: String(localized: "chat.delivery.failed", bundle: .module),
      unknownSender: String(localized: "chat.sender.unknown", bundle: .module)
    )
  }
}
