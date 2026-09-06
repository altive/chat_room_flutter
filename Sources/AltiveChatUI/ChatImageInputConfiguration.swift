import Foundation

/// 入力欄から追加できる画像の取得元。
public enum ChatImageInputSource: Hashable, Identifiable, Sendable {
  /// アプリ側のカメラUIで撮影する。
  case camera

  /// システムの写真ライブラリから選択する。
  case photoLibrary

  /// システムのファイル選択UIから選択する。
  case file

  /// システムの貼り付けUIまたは入力欄から追加する。
  case clipboard

  public var id: Self { self }
}

/// 画像入力機能の設定。
public struct ChatImageInputConfiguration: Hashable, Sendable {
  /// すべての取得元を合わせた最大添付枚数。
  public var maximumSelectionCount: Int {
    didSet {
      precondition(maximumSelectionCount > 0, "maximumSelectionCount must be greater than zero")
    }
  }

  /// 画像入力機能の設定を作成する。
  public init(maximumSelectionCount: Int = 4) {
    precondition(maximumSelectionCount > 0, "maximumSelectionCount must be greater than zero")
    self.maximumSelectionCount = maximumSelectionCount
  }
}
