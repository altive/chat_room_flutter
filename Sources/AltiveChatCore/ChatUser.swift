import Foundation

/// チャットへ表示するユーザー。
public struct ChatUser: Hashable, Identifiable, Sendable {
  /// ユーザーを一意に識別する値。
  public let id: String

  /// チャットへ表示する名前。
  public var displayName: String

  /// アバター画像の取得先。
  public var avatarURL: URL?

  /// チャットへ表示するユーザーを作成する。
  public init(
    id: String,
    displayName: String,
    avatarURL: URL? = nil
  ) {
    self.id = id
    self.displayName = displayName
    self.avatarURL = avatarURL
  }
}
