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
  ///
  /// 標準シートへ統一したため、現在は ``system`` と同じ動作をする。
  @available(*, deprecated, message: "写真ライブラリはシステム標準シートで表示されます")
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

  /// 互換性のために残している旧inline表示用の設定。現在は使用しない。
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
