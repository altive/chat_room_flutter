import Foundation
import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

/// consumerが検証済みassetから解決したステッカー画像。
public struct ChatResolvedSticker: Sendable {
  /// 表示する画像data。
  public let imageData: Data

  /// asset manifestなどから解決した読み上げ文。
  public let accessibilityLabel: String?

  /// 解決済みステッカーを作成する。
  public init(imageData: Data, accessibilityLabel: String? = nil) {
    self.imageData = imageData
    self.accessibilityLabel = accessibilityLabel
  }
}

/// ステッカー参照を検証済み画像へ解決する処理。
public struct ChatStickerImageLoader: Sendable {
  private let load: @Sendable (ChatStickerReference) async throws -> ChatResolvedSticker

  /// consumer固有のasset解決処理を作成する。
  public init(
    load: @escaping @Sendable (ChatStickerReference) async throws -> ChatResolvedSticker
  ) {
    self.load = load
  }

  /// 指定したステッカーの検証済み画像を返す。
  public func sticker(for reference: ChatStickerReference) async throws -> ChatResolvedSticker {
    try await load(reference)
  }
}

/// ステッカーメッセージの共通寸法。
public enum ChatStickerMessageMetrics {
  /// タイムライン内の1辺。
  public static let displayLength: CGFloat = 176
}

/// 読み込み・失敗・再試行を含むステッカーメッセージ本文。
@MainActor
public struct ChatStickerMessageContent: View {
  enum Phase: Equatable {
    case loading
    case success(ChatResolvedSticker)
    case failure

    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.loading, .loading), (.failure, .failure): true
      case (.success(let lhs), .success(let rhs)):
        lhs.imageData == rhs.imageData && lhs.accessibilityLabel == rhs.accessibilityLabel
      default: false
      }
    }
  }

  private let reference: ChatStickerReference
  private let imageLoader: ChatStickerImageLoader?
  private let stickerLabel: String
  private let loadingFailureLabel: String

  @State private var phase = Phase.loading
  @State private var retryID = 0

  /// ステッカーメッセージ本文を作成する。
  public init(
    reference: ChatStickerReference,
    imageLoader: ChatStickerImageLoader?,
    stickerLabel: String = "Sticker",
    loadingFailureLabel: String = "Failed to load sticker"
  ) {
    self.reference = reference
    self.imageLoader = imageLoader
    self.stickerLabel = stickerLabel
    self.loadingFailureLabel = loadingFailureLabel
  }

  public var body: some View {
    Button {
      if case .failure = phase { retryID += 1 }
    } label: {
      phaseContent
        .frame(
          width: ChatStickerMessageMetrics.displayLength,
          height: ChatStickerMessageMetrics.displayLength
        )
        .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(effectiveAccessibilityLabel)
    .task(id: LoadTaskID(reference: reference, retryID: retryID)) {
      guard let imageLoader else {
        phase = .failure
        return
      }
      phase = .loading
      do {
        let sticker = try await imageLoader.sticker(for: reference)
        try Task.checkCancellation()
        phase = isDecodableImage(sticker.imageData) ? .success(sticker) : .failure
      } catch is CancellationError {
        return
      } catch {
        phase = .failure
      }
    }
  }

  @ViewBuilder
  private var phaseContent: some View {
    switch phase {
    case .loading:
      ProgressView()
    case .success(let sticker):
      decodedImage(sticker.imageData)
    case .failure:
      VStack(spacing: 6) {
        Image(systemName: "arrow.clockwise")
          .font(.title3)
        Text(loadingFailureLabel)
          .font(.caption2)
          .multilineTextAlignment(.center)
          .lineLimit(2)
      }
      .foregroundStyle(.secondary)
      .padding(8)
    }
  }

  private var effectiveAccessibilityLabel: String {
    switch phase {
    case .success(let sticker):
      if let accessibilityLabel = sticker.accessibilityLabel, !accessibilityLabel.isEmpty {
        accessibilityLabel
      } else {
        stickerLabel
      }
    case .failure:
      loadingFailureLabel
    case .loading:
      stickerLabel
    }
  }

  private func isDecodableImage(_ data: Data) -> Bool {
    #if canImport(UIKit)
      UIImage(data: data) != nil
    #elseif canImport(AppKit)
      NSImage(data: data) != nil
    #else
      false
    #endif
  }

  @ViewBuilder
  private func decodedImage(_ data: Data) -> some View {
    #if canImport(UIKit)
      if let platformImage = UIImage(data: data) {
        Image(uiImage: platformImage).resizable().scaledToFit()
      } else {
        decodeFailure
      }
    #elseif canImport(AppKit)
      if let platformImage = NSImage(data: data) {
        Image(nsImage: platformImage).resizable().scaledToFit()
      } else {
        decodeFailure
      }
    #else
      decodeFailure
    #endif
  }

  private var decodeFailure: some View {
    Image(systemName: "photo.badge.exclamationmark")
      .foregroundStyle(.secondary)
      .accessibilityLabel(loadingFailureLabel)
  }

  private struct LoadTaskID: Hashable {
    let reference: ChatStickerReference
    let retryID: Int
  }
}
