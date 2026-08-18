import Foundation

/// チャットで選択できるリアクションの表示値。
public struct ChatReaction: Hashable, Identifiable, Sendable {
  /// APIやアプリ固有型との変換に使う安定ID。
  public let id: String

  /// 画面へ表示する記号。
  public let symbol: String

  /// VoiceOverへ伝える名前。
  public let accessibilityLabel: String

  /// リアクションの表示値を作成する。
  public init(id: String, symbol: String, accessibilityLabel: String) {
    self.id = id
    self.symbol = symbol
    self.accessibilityLabel = accessibilityLabel
  }

  /// ハート。
  public static let heart = ChatReaction(id: "heart", symbol: "❤️", accessibilityLabel: "❤️")

  /// いいね。
  public static let like = ChatReaction(id: "like", symbol: "👍", accessibilityLabel: "👍")

  /// お祝い。
  public static let celebrate = ChatReaction(
    id: "celebrate",
    symbol: "🎉",
    accessibilityLabel: "🎉"
  )

  /// 感謝。
  public static let thanks = ChatReaction(id: "thanks", symbol: "🙏", accessibilityLabel: "🙏")

  /// 応援。
  public static let cheer = ChatReaction(id: "cheer", symbol: "👏", accessibilityLabel: "👏")

  /// ファネリーとノコリスで共通利用する標準候補。
  public static let standard: [ChatReaction] = [.heart, .like, .celebrate, .thanks, .cheer]
}

/// リアクションと現在件数の組み合わせ。
public struct ChatReactionCount: Hashable, Identifiable, Sendable {
  /// 表示するリアクション。
  public let reaction: ChatReaction

  /// 現在件数。
  public let count: Int

  /// リアクションID。
  public var id: String { reaction.id }

  /// 件数表示を作成する。
  public init(reaction: ChatReaction, count: Int) {
    self.reaction = reaction
    self.count = max(0, count)
  }
}

/// 楽観的更新と競合を壊さないロールバックに必要な値を保持する。
public struct ChatOptimisticMutation<Value>: Sendable where Value: Equatable & Sendable {
  /// 更新前の値。
  public let previousValue: Value

  /// 楽観的に反映する値。
  public let optimisticValue: Value

  /// 更新前の値へ純粋な変更を適用して作成する。
  public init(previousValue: Value, applying update: (inout Value) -> Void) {
    self.previousValue = previousValue
    var optimisticValue = previousValue
    update(&optimisticValue)
    self.optimisticValue = optimisticValue
  }

  /// 現在値が自分の楽観的更新のままなら更新前へ戻す。
  public func rollingBack(currentValue: Value) -> Value {
    currentValue == optimisticValue ? previousValue : currentValue
  }
}
