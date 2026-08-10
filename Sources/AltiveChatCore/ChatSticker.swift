import Foundation

/// CDN URLを含まない固定revisionのステッカー参照。
public struct ChatStickerReference: Hashable, Sendable {
  /// パックID。
  public let packID: String

  /// ステッカーID。
  public let stickerID: String

  /// 送信時に固定した画像locale。
  public let locale: String

  /// 配信asset revision。
  public let assetRevision: Int

  /// ステッカー参照を作成する。
  public init(packID: String, stickerID: String, locale: String, assetRevision: Int) {
    self.packID = packID
    self.stickerID = stickerID
    self.locale = locale
    self.assetRevision = assetRevision
  }
}

/// 最近利用した値の順序と件数上限を共通化する処理。
public enum ChatRecentItems {
  /// 指定値を先頭へ移し、重複を除いて上限へ丸める。
  public static func updating<Value>(
    _ current: [Value],
    adding value: Value,
    limit: Int = 40
  ) -> [Value] where Value: Equatable & Sendable {
    guard limit > 0 else { return [] }
    return Array(([value] + current.filter { $0 != value }).prefix(limit))
  }
}
