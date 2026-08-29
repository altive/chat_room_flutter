import Foundation
import Testing

@testable import AltiveChatUI

@MainActor
@Suite("入力中Webリンクプレビュー", .serialized)
struct ChatLinkPreviewDraftTests {
  actor ResolverCalls {
    private(set) var urls: [URL] = []

    func append(_ url: URL) {
      urls.append(url)
    }

    func count() -> Int {
      urls.count
    }
  }

  @Test("debounce後に同じURLを1回だけ解決する")
  func resolvesSameURLOnlyOnce() async throws {
    let calls = ResolverCalls()
    let coordinator = ChatLinkPreviewDraftCoordinator(
      resolver: { url in
        await calls.append(url)
        return preview(url: url, title: "Example")
      },
      debounce: .milliseconds(10)
    )

    coordinator.update(draft: "https://example.jp")
    coordinator.update(draft: "本文 https://example.jp")
    try await Task.sleep(for: .milliseconds(500))

    #expect(await calls.count() == 1)
    guard case .loaded(let loaded) = coordinator.state else {
      Issue.record("previewが解決済みになる必要があります")
      return
    }
    #expect(loaded.title == "Example")
  }

  @Test("URL変更後に戻った古いresolver結果を採用しない")
  func discardsStaleResult() async throws {
    let coordinator = ChatLinkPreviewDraftCoordinator(
      resolver: { url in
        if url.host == "first.example" {
          try? await Task.sleep(for: .milliseconds(80))
          return preview(url: url, title: "古い結果")
        }
        try await Task.sleep(for: .milliseconds(5))
        return preview(url: url, title: "新しい結果")
      },
      debounce: .milliseconds(5)
    )

    coordinator.update(draft: "https://first.example")
    try await Task.sleep(for: .milliseconds(15))
    coordinator.update(draft: "https://second.example")
    try await Task.sleep(for: .milliseconds(300))

    guard case .loaded(let loaded) = coordinator.state else {
      Issue.record("新しいpreviewが表示される必要があります")
      return
    }
    #expect(loaded.title == "新しい結果")
    #expect(coordinator.selectedURL?.host == "second.example")
  }

  @Test("resolver未指定、失敗、previewなしでは本文だけへ戻る")
  func fallsBackWithoutPreview() async throws {
    let withoutResolver = ChatLinkPreviewDraftCoordinator(resolver: nil)
    withoutResolver.update(draft: "https://example.jp")
    #expect(withoutResolver.state == .idle)

    let failed = ChatLinkPreviewDraftCoordinator(
      resolver: { _ in throw URLError(.cannotConnectToHost) },
      debounce: .milliseconds(1)
    )
    failed.update(draft: "https://example.jp")
    try await Task.sleep(for: .milliseconds(150))
    #expect(failed.state == .idle)

    let empty = ChatLinkPreviewDraftCoordinator(
      resolver: { _ in nil },
      debounce: .milliseconds(1)
    )
    empty.update(draft: "https://example.jp")
    try await Task.sleep(for: .milliseconds(150))
    #expect(empty.state == .idle)
  }

  @Test("要求URLと異なるresolver結果を採用しない")
  func rejectsMismatchedResolverResult() async throws {
    let coordinator = ChatLinkPreviewDraftCoordinator(
      resolver: { _ in
        preview(url: URL(string: "https://other.example")!, title: "別URL")
      },
      debounce: .milliseconds(1)
    )

    coordinator.update(draft: "https://example.jp")
    try await Task.sleep(for: .milliseconds(150))

    #expect(coordinator.state == .idle)
  }

  @Test("取得中でもpreviewなしのsubmissionを即座に作れる")
  func permitsSubmissionWhileLoading() throws {
    let coordinator = ChatLinkPreviewDraftCoordinator(
      resolver: { url in preview(url: url, title: "Example") },
      debounce: .seconds(10)
    )
    let text = "https://example.jp"
    coordinator.update(draft: text)

    let submission = try #require(
      ChatComposerSubmission(
        text: text,
        images: [],
        linkPreview: coordinator.previewForSubmission(text: text)
      )
    )

    #expect(coordinator.state != .idle)
    #expect(submission.linkPreview == nil)
  }

  @Test("opaqueな画像参照だけをアプリloaderへ渡す")
  func delegatesImageLoading() async throws {
    let loader = ChatLinkPreviewImageLoader { resource in
      #expect(resource == "preview/hash/image.webp")
      return Data([0x01, 0x02])
    }

    #expect(try await loader.data(for: "preview/hash/image.webp") == Data([0x01, 0x02]))
  }

  @Test("全fieldのカードを画像loaderとtap callback付きで構築できる")
  func createsFullCard() {
    let url = URL(string: "https://example.jp")!
    let card = ChatLinkPreviewCard(
      preview: ChatLinkPreview(
        sourceURL: url,
        title: "タイトル",
        description: "説明",
        siteName: "Example",
        image: ChatLinkPreviewImage(resource: "image", pixelWidth: 1200, pixelHeight: 630)
      )!,
      imageLoader: ChatLinkPreviewImageLoader { _ in Data() },
      accessibilityLabel: "リンクプレビュー",
      onTap: { _ in }
    )

    _ = card.body
  }
}

private func preview(url: URL, title: String) -> ChatLinkPreview {
  ChatLinkPreview(sourceURL: url, title: title)!
}
