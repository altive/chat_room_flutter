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
}

/// 画像メッセージを1〜4区画へ配置するグリッド。
@MainActor
public struct ChatImageGrid: View {
  private let messageID: String
  private let images: [ChatImage]
  private let imageLoader: ChatImageLoader
  private let imageLabel: String
  private let loadingFailureLabel: String
  private let onImageTap: ((String, Int) -> Void)?

  /// 画像グリッドを作成する。
  public init(
    messageID: String,
    images: [ChatImage],
    imageLoader: ChatImageLoader = .standard,
    imageLabel: String = "Image",
    loadingFailureLabel: String = "Failed to load image",
    onImageTap: ((String, Int) -> Void)? = nil
  ) {
    self.messageID = messageID
    self.images = images
    self.imageLoader = imageLoader
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
        HStack(spacing: 3) {
          tile(at: 0)
          tile(at: 1)
        }
        .frame(width: 267, height: 176)
      case 3:
        HStack(spacing: 3) {
          tile(at: 0)
            .frame(width: 176)
          VStack(spacing: 3) {
            tile(at: 1)
            tile(at: 2)
          }
        }
        .frame(width: 267, height: 221)
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

  private var visibleImages: ArraySlice<ChatImage> {
    images.prefix(ChatImageGridMetrics.visibleCount(for: images.count))
  }

  private var singleImageHeight: CGFloat {
    guard let image = visibleImages.first,
      let width = image.pixelWidth,
      let height = image.pixelHeight,
      width > 0,
      height > 0
    else { return 220 }
    return min(260, max(160, 240 / CGFloat(width) * CGFloat(height)))
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
  private enum Phase {
    case loading
    case success(Data)
    case failure
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
      phase = .loading
      do {
        let data = try await imageLoader.data(for: image.resource)
        try Task.checkCancellation()
        phase = .success(data)
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
