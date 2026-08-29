import AltiveChatCore

/// Roomで返信を開始・表示するための設定。
@MainActor
public struct ChatReplyConfiguration {
  private let canReplyHandler: (ChatMessage) -> Bool
  private let makeReferenceHandler: (ChatMessage, Int?) -> ChatReplyReference?

  /// 引用をタップしたときの処理。
  public let onReferenceTap: ((String, Int?) -> Void)?

  /// 返信設定を作成する。
  public init(
    canReply: @escaping (ChatMessage) -> Bool = { _ in true },
    makeReference: @escaping (ChatMessage, Int?) -> ChatReplyReference? = {
      ChatReplyReference(message: $0, imageIndex: $1)
    },
    onReferenceTap: ((String, Int?) -> Void)? = nil
  ) {
    canReplyHandler = canReply
    makeReferenceHandler = makeReference
    self.onReferenceTap = onReferenceTap
  }

  /// package既定条件とapp固有条件を満たす返信参照を返す。
  func reference(for message: ChatMessage, imageIndex: Int? = nil) -> ChatReplyReference? {
    guard Self.isStandardReplyTarget(message), canReplyHandler(message) else { return nil }
    return makeReferenceHandler(message, imageIndex)
  }

  private static func isStandardReplyTarget(_ message: ChatMessage) -> Bool {
    guard message.deliveryState == .sent, message.sender != nil else { return false }
    if case .system = message.content { return false }
    return true
  }
}
