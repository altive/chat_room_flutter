import Foundation

/// 入力欄から追加できる画像の取得元。
public enum ChatImageInputSource: Hashable, Identifiable, Sendable {
  /// アプリ側のカメラUIで撮影する。
  case camera

  /// システムの写真ライブラリから選択する。
  case photoLibrary

  public var id: Self { self }
}

/// 写真ライブラリを表示する方法。
public enum ChatPhotoLibraryPresentationStyle: Hashable, Sendable {
  /// システム標準のモーダルPhotos Picker。
  case system

  /// キーボードと同じ入力面へ埋め込むPhotos Picker。
  case inline
}

/// 画像入力機能の設定。
public struct ChatImageInputConfiguration: Hashable, Sendable {
  /// 写真ライブラリを表示する方法。
  public var photoLibraryPresentationStyle: ChatPhotoLibraryPresentationStyle

  /// カメラと写真ライブラリを合わせた最大添付枚数。
  public var maximumSelectionCount: Int {
    didSet {
      precondition(maximumSelectionCount > 0, "maximumSelectionCount must be greater than zero")
    }
  }

  /// inline表示をドラッグハンドルで拡張できるか。
  public var allowsInlineExpansion: Bool

  /// 画像入力機能の設定を作成する。
  public init(
    photoLibraryPresentationStyle: ChatPhotoLibraryPresentationStyle = .system,
    maximumSelectionCount: Int = 4,
    allowsInlineExpansion: Bool = true
  ) {
    precondition(maximumSelectionCount > 0, "maximumSelectionCount must be greater than zero")
    self.photoLibraryPresentationStyle = photoLibraryPresentationStyle
    self.maximumSelectionCount = maximumSelectionCount
    self.allowsInlineExpansion = allowsInlineExpansion
  }
}
