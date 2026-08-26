import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

/// 複数画像表示で利用する件数計算。
public enum ChatImageGridMetrics {
  /// 一覧内へ実際に表示する最大4枚の件数。
  public static func visibleCount(for imageCount: Int) -> Int {
    min(max(0, imageCount), 4)
  }

  /// 4枚目へ重ねる未表示枚数。
  public static func overflowCount(for imageCount: Int) -> Int {
    max(0, imageCount - 4)
  }

  /// 単一画像の縦横比と配置方法から表示高を返す。
  public static func singleImageHeight(
    pixelWidth: Int?,
    pixelHeight: Int?,
    layout: ChatSingleImageLayout,
    displayWidth: CGFloat = 240
  ) -> CGFloat {
    switch layout {
    case .square:
      return displayWidth
    case .adaptiveBounded(let minHeight, let maxHeight):
      let normalizedMinHeight = max(1, minHeight)
      let normalizedMaxHeight = max(normalizedMinHeight, maxHeight)
      guard let pixelWidth, let pixelHeight, pixelWidth > 0, pixelHeight > 0 else {
        return min(normalizedMaxHeight, max(normalizedMinHeight, 220))
      }
      return min(
        normalizedMaxHeight,
        max(normalizedMinHeight, displayWidth / CGFloat(pixelWidth) * CGFloat(pixelHeight))
      )
    }
  }
}

/// 複数画像をメッセージ内へ配置する方法。
public enum ChatMultipleImageLayout: Hashable, Sendable {
  /// 3枚では先頭を大きく配置し、右側へ残り2枚を並べる。
  case mosaic

  /// 3枚では先頭を横長にし、残りを下段へ配置する。
  case leadingWideGrid
}

/// 単一画像メッセージの配置方法。
public enum ChatSingleImageLayout: Hashable, Sendable {
  /// 元画像の縦横比を指定した高さの範囲で維持する。
  case adaptiveBounded(minHeight: CGFloat = 160, maxHeight: CGFloat = 260)

  /// 従来互換の正方形表示。
  case square
}

/// 画像メッセージを1〜4区画へ配置するグリッド。
@MainActor
public struct ChatImageGrid: View {
  private let messageID: String
  private let images: [ChatImage]
  private let imageLoader: ChatImageLoader
  private let singleImageLayout: ChatSingleImageLayout
  private let multipleImageLayout: ChatMultipleImageLayout
  private let imageLabel: String
  private let loadingFailureLabel: String
  private let onImageTap: ((String, Int) -> Void)?

  /// 画像グリッドを作成する。
  public init(
    messageID: String,
    images: [ChatImage],
    imageLoader: ChatImageLoader = .standard,
    singleImageLayout: ChatSingleImageLayout = .adaptiveBounded(),
    multipleImageLayout: ChatMultipleImageLayout = .mosaic,
    imageLabel: String = "Image",
    loadingFailureLabel: String = "Failed to load image",
    onImageTap: ((String, Int) -> Void)? = nil
  ) {
    self.messageID = messageID
    self.images = images
    self.imageLoader = imageLoader
    self.singleImageLayout = singleImageLayout
    self.multipleImageLayout = multipleImageLayout
    self.imageLabel = imageLabel
    self.loadingFailureLabel = loadingFailureLabel
    self.onImageTap = onImageTap
  }

  public var body: some View {
    Group {
      switch visibleImages.count {
      case 0:
        EmptyView()
      case 1:
        tile(at: 0)
          .frame(width: 240, height: singleImageHeight)
      case 2:
        twoImageGrid
      case 3:
        threeImageGrid
      default:
        VStack(spacing: 3) {
          HStack(spacing: 3) {
            tile(at: 0)
            tile(at: 1)
          }
          HStack(spacing: 3) {
            tile(at: 2)
            tile(at: 3, overflowCount: ChatImageGridMetrics.overflowCount(for: images.count))
          }
        }
        .frame(width: 267, height: 267)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }

  private var twoImageGrid: some View {
    HStack(spacing: 3) {
      tile(at: 0)
      tile(at: 1)
    }
    .frame(width: 267, height: 176)
  }

  @ViewBuilder
  private var threeImageGrid: some View {
    switch multipleImageLayout {
    case .mosaic:
      HStack(spacing: 3) {
        tile(at: 0)
          .frame(width: 176)
        VStack(spacing: 3) {
          tile(at: 1)
          tile(at: 2)
        }
      }
      .frame(width: 267, height: 221)
    case .leadingWideGrid:
      VStack(spacing: 3) {
        tile(at: 0)
        HStack(spacing: 3) {
          tile(at: 1)
          tile(at: 2)
        }
      }
      .frame(width: 267, height: 267)
    }
  }

  private var visibleImages: ArraySlice<ChatImage> {
    images.prefix(ChatImageGridMetrics.visibleCount(for: images.count))
  }

  private var singleImageHeight: CGFloat {
    let image = visibleImages.first
    return ChatImageGridMetrics.singleImageHeight(
      pixelWidth: image?.pixelWidth,
      pixelHeight: image?.pixelHeight,
      layout: singleImageLayout
    )
  }

  private func tile(at index: Int, overflowCount: Int = 0) -> some View {
    let image = visibleImages[visibleImages.index(visibleImages.startIndex, offsetBy: index)]
    return ChatImageTile(
      image: image,
      imageLoader: imageLoader,
      fallbackLabel: imageLabel,
      loadingFailureLabel: loadingFailureLabel,
      overflowCount: overflowCount,
      onTap: onImageTap.map { callback in
        { callback(messageID, index) }
      }
    )
  }
}

@MainActor
struct ChatImageTile: View {
  enum Phase: Equatable {
    case loading
    case success(Data)
    case failure

    /// 別resourceの読み込み開始時に表示する状態を返す。
    var startingReplacement: Self {
      if case .success = self { return self }
      return .loading
    }

    /// 別resourceの読み込み失敗時に表示する状態を返す。
    var failingReplacement: Self {
      if case .success = self { return self }
      return .failure
    }
  }

  let image: ChatImage
  let imageLoader: ChatImageLoader
  let fallbackLabel: String
  let loadingFailureLabel: String
  let overflowCount: Int
  let onTap: (() -> Void)?

  @State private var phase = Phase.loading
  @State private var retryID = 0

  var body: some View {
    Button {
      if case .failure = phase {
        retryID += 1
      } else {
        onTap?()
      }
    } label: {
      ZStack {
        Color.secondary.opacity(0.12)
        phaseContent

        if overflowCount > 0 {
          Color.black.opacity(0.48)
          Text(verbatim: "+\(overflowCount)")
            .font(.title2.bold())
            .foregroundStyle(.white)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(image.accessibilityLabel ?? fallbackLabel)
    .task(id: LoadTaskID(resource: image.resource, retryID: retryID)) {
      // 同一画像がローカルからリモートへ切り替わる間も、ちらつきを避けるため
      // 読み込み済みの旧画像を残す。
      let previousPhase = phase
      phase = previousPhase.startingReplacement
      do {
        let data = try await imageLoader.data(for: image.resource)
        try Task.checkCancellation()
        phase = .success(data)
      } catch is CancellationError {
        return
      } catch {
        // 既に表示できる画像がある場合、次の再描画まで利用可能な表示を維持する。
        phase = previousPhase.failingReplacement
      }
    }
  }

  @ViewBuilder
  private var phaseContent: some View {
    switch phase {
    case .loading:
      ProgressView()
    case .success(let data):
      decodedImage(data)
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

  @ViewBuilder
  private func decodedImage(_ data: Data) -> some View {
    #if canImport(UIKit)
      if let platformImage = UIImage(data: data) {
        Image(uiImage: platformImage)
          .resizable()
          .scaledToFill()
      } else {
        decodeFailure
      }
    #elseif canImport(AppKit)
      if let platformImage = NSImage(data: data) {
        Image(nsImage: platformImage)
          .resizable()
          .scaledToFill()
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
    let resource: ChatImageResource
    let retryID: Int
  }
}
