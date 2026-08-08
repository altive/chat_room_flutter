import Foundation

/// チャットメッセージの表示内容。
public enum ChatMessageContent: Hashable, Sendable {
  /// ユーザーが送信したテキスト。
  case text(String)

  /// 会話内へ中央寄せで表示するシステム文言。
  case system(String)
}

/// メッセージの送信状態。
public enum ChatMessageDeliveryState: Hashable, Sendable {
  /// サーバーへ反映済み。
  case sent

  /// サーバーへ送信中。
  case sending

  /// 送信に失敗。
  case failed
}

/// チャットへ表示するメッセージ。
public struct ChatMessage: Hashable, Identifiable, Sendable {
  /// メッセージを一意に識別する値。
  public let id: String

  /// メッセージの作成日時。
  public let createdAt: Date

  /// メッセージの送信者。システムメッセージでは `nil` を許容する。
  public let sender: ChatUser?

  /// メッセージの表示内容。
  public let content: ChatMessageContent

  /// メッセージの送信状態。
  public let deliveryState: ChatMessageDeliveryState

  /// チャットへ表示するメッセージを作成する。
  public init(
    id: String,
    createdAt: Date,
    sender: ChatUser?,
    content: ChatMessageContent,
    deliveryState: ChatMessageDeliveryState = .sent
  ) {
    self.id = id
    self.createdAt = createdAt
    self.sender = sender
    self.content = content
    self.deliveryState = deliveryState
  }

  /// 指定したユーザーが送信したメッセージかどうかを返す。
  public func isSent(by userID: String) -> Bool {
    sender?.id == userID
  }
}
