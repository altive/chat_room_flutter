import Foundation
import Observation
import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

/// 入力中のURLからリンクプレビューを取得する処理。
public typealias ChatLinkPreviewResolver = @Sendable (URL) async throws -> ChatLinkPreview?

/// opaqueな画像参照からリンクプレビュー画像を読み込む処理。
public struct ChatLinkPreviewImageLoader: Sendable {
  private let loadData: @Sendable (String) async throws -> Data

  /// アプリ固有の画像参照を解決するloaderを作成する。
  public init(loadData: @escaping @Sendable (String) async throws -> Data) {
    self.loadData = loadData
  }

  /// 指定したopaqueな参照の画像dataを返す。
  public func data(for resource: String) async throws -> Data {
    try await loadData(resource)
  }
}

@MainActor
@Observable
public final class ChatLinkPreviewDraftCoordinator {
  /// 入力中リンクプレビューの表示状態。
  public enum State: Equatable {
    case idle
    case loading(URL)
    case loaded(ChatLinkPreview)
  }

  /// 現在の表示状態。
  public private(set) var state: State = .idle

  /// 現在選択している本文先頭URL。
  public private(set) var selectedURL: URL?

  private let resolver: ChatLinkPreviewResolver?
  private let debounce: Duration
  private var task: Task<Void, Never>?

  /// resolverとdebounce時間から入力状態を作成する。
  public init(
    resolver: ChatLinkPreviewResolver?,
    debounce: Duration = .milliseconds(500)
  ) {
    self.resolver = resolver
    self.debounce = debounce
  }

  /// draft変更を反映し、必要なresolver処理を開始する。
  public func update(draft: String) {
    let nextURL = ChatWebURLParser.firstURL(in: draft)
    guard nextURL != selectedURL else { return }

    task?.cancel()
    selectedURL = nextURL
    guard let nextURL, let resolver else {
      state = .idle
      return
    }

    state = .loading(nextURL)
    let debounce = self.debounce
    task = Task { [weak self] in
      do {
        try await Task.sleep(for: debounce)
        let preview = try await resolver(nextURL)
        try Task.checkCancellation()
        guard let self, self.selectedURL == nextURL else { return }
        if let preview, preview.sourceURL == nextURL {
          state = .loaded(preview)
        } else {
          state = .idle
        }
      } catch is CancellationError {
        return
      } catch {
        guard let self, self.selectedURL == nextURL else { return }
        state = .idle
      }
    }
  }

  /// 現在の本文と一致する解決済みpreviewを送信値として返す。
  public func previewForSubmission(text: String?) -> ChatLinkPreview? {
    guard let text,
      ChatWebURLParser.firstURL(in: text) == selectedURL,
      case .loaded(let preview) = state
    else { return nil }
    return preview
  }
}

/// 解決済みmetadataを表示するリンクプレビュー用カード。
@MainActor
public struct ChatLinkPreviewCard: View {
  private let preview: ChatLinkPreview
  private let imageLoader: ChatLinkPreviewImageLoader?
  private let accessibilityLabel: String
  private let onTap: ((URL) -> Void)?

  @Environment(\.openURL) private var openURL

  /// リンクプレビューカードを作成する。
  public init(
    preview: ChatLinkPreview,
    imageLoader: ChatLinkPreviewImageLoader? = nil,
    accessibilityLabel: String = "Link preview",
    onTap: ((URL) -> Void)? = nil
  ) {
    self.preview = preview
    self.imageLoader = imageLoader
    self.accessibilityLabel = accessibilityLabel
    self.onTap = onTap
  }

  public var body: some View {
    Button {
      if let onTap {
        onTap(preview.sourceURL)
      } else {
        openURL(preview.sourceURL)
      }
    } label: {
      VStack(alignment: .leading, spacing: 0) {
        if let image = preview.image, let imageLoader {
          ChatLinkPreviewImageView(image: image, imageLoader: imageLoader)
        }

        VStack(alignment: .leading, spacing: 4) {
          if let siteName = preview.siteName {
            Text(siteName)
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }

          Text(preview.title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
            .lineLimit(2)

          if let description = preview.description {
            Text(description)
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(3)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
      }
      .background(.background.opacity(0.92))
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(.secondary.opacity(0.24), lineWidth: 0.5)
      }
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityDescription)
    .accessibilityAddTraits(.isLink)
  }

  private var accessibilityDescription: String {
    [
      accessibilityLabel,
      preview.siteName,
      preview.title,
      preview.description,
      preview.sourceURL.absoluteString,
    ]
    .compactMap { $0 }
    .joined(separator: ", ")
  }
}

@MainActor
public struct ChatLinkPreviewDraftContent: View {
  private let state: ChatLinkPreviewDraftCoordinator.State
  private let imageLoader: ChatLinkPreviewImageLoader?
  private let accessibilityLabel: String
  private let loadingLabel: String
  private let onTap: ((URL) -> Void)?

  /// 入力中リンクプレビューのloadingまたはカードを作成する。
  public init(
    state: ChatLinkPreviewDraftCoordinator.State,
    imageLoader: ChatLinkPreviewImageLoader? = nil,
    accessibilityLabel: String = "Link preview",
    loadingLabel: String = "Loading link preview",
    onTap: ((URL) -> Void)? = nil
  ) {
    self.state = state
    self.imageLoader = imageLoader
    self.accessibilityLabel = accessibilityLabel
    self.loadingLabel = loadingLabel
    self.onTap = onTap
  }

  @ViewBuilder
  public var body: some View {
    switch state {
    case .idle:
      EmptyView()
    case .loading:
      HStack(spacing: 10) {
        ProgressView()
        Text(loadingLabel)
          .font(.caption)
          .foregroundStyle(.secondary)
        Spacer(minLength: 0)
      }
      .padding(12)
      .frame(maxWidth: .infinity, minHeight: 64)
      .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
      .accessibilityElement(children: .combine)
    case .loaded(let preview):
      ChatLinkPreviewCard(
        preview: preview,
        imageLoader: imageLoader,
        accessibilityLabel: accessibilityLabel,
        onTap: onTap
      )
    }
  }
}

@MainActor
private struct ChatLinkPreviewImageView: View {
  let image: ChatLinkPreviewImage
  let imageLoader: ChatLinkPreviewImageLoader

  @State private var imageData: Data?

  var body: some View {
    Group {
      if let imageData {
        decodedImage(imageData)
          .aspectRatio(
            CGFloat(image.pixelWidth) / CGFloat(image.pixelHeight),
            contentMode: .fit
          )
          .frame(maxWidth: .infinity)
          .clipped()
      }
    }
    .task(id: image.resource) {
      imageData = nil
      do {
        let data = try await imageLoader.data(for: image.resource)
        try Task.checkCancellation()
        guard isDecodable(data) else { return }
        imageData = data
      } catch {
        imageData = nil
      }
    }
    .accessibilityHidden(true)
  }

  @ViewBuilder
  private func decodedImage(_ data: Data) -> some View {
    #if canImport(UIKit)
      if let platformImage = UIImage(data: data) {
        Image(uiImage: platformImage).resizable()
      }
    #elseif canImport(AppKit)
      if let platformImage = NSImage(data: data) {
        Image(nsImage: platformImage).resizable()
      }
    #endif
  }

  private func isDecodable(_ data: Data) -> Bool {
    #if canImport(UIKit)
      UIImage(data: data) != nil
    #elseif canImport(AppKit)
      NSImage(data: data) != nil
    #else
      false
    #endif
  }
}
