import Foundation

/// システムイベントの共通表示値。
public struct ChatSystemEventItem: Hashable, Identifiable, Sendable {
  /// イベントを一意に識別する値。
  public let id: String

  /// イベントの発生日時。
  public let occurredAt: Date

  /// アプリ側でローカライズ済みの表示文。
  public let message: String

  /// システムイベントの表示値を作成する。
  public init(id: String, occurredAt: Date, message: String) {
    self.id = id
    self.occurredAt = occurredAt
    self.message = message
  }
}
