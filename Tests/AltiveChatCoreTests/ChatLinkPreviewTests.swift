import Foundation
import Testing

@testable import AltiveChatCore

@Suite("Webリンクプレビュー")
struct ChatLinkPreviewTests {
  @Test("先頭のWeb URLだけを選び末尾句読点を除く")
  func selectsFirstWebURL() {
    let text = "先頭 https://first.example/path）。次は https://second.example"

    #expect(
      ChatWebURLParser.firstURL(in: text)
        == URL(string: "https://first.example/path")
    )
  }

  @Test("未対応schemeとメールアドレスを入力中preview対象にしない")
  func rejectsUnsupportedDraftURLs() {
    #expect(ChatWebURLParser.firstURL(in: "ftp://example.jp") == nil)
    #expect(ChatWebURLParser.firstURL(in: "javascript:https://example.jp") == nil)
    #expect(ChatWebURLParser.firstURL(in: "support@example.jp") == nil)
  }

  @Test("共通fixtureのURL選択を全件満たす")
  func matchesSharedSelectionFixture() throws {
    let testDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let fixtureURL =
      testDirectory
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "contract/fixtures/link-preview-cases.json")
    let fixture = try JSONDecoder().decode(
      LinkPreviewFixture.self,
      from: Data(contentsOf: fixtureURL)
    )

    for selectionCase in fixture.selectionCases {
      let expectedURL = selectionCase.sourceUrl.flatMap(URL.init(string:))
      #expect(
        ChatWebURLParser.firstURL(in: selectionCase.text) == expectedURL,
        Comment(rawValue: selectionCase.name)
      )
    }
  }

  @Test("schemeとhostおよび既定portを正規化する")
  func normalizesDraftURL() {
    #expect(
      ChatWebURLParser.firstURL(in: "HTTPS://EXAMPLE.JP:443/path")
        == URL(string: "https://example.jp/path")
    )
    #expect(
      ChatWebURLParser.firstURL(in: "www.example.com/news")
        == URL(string: "https://www.example.com/news")
    )
  }

  @Test("表示値を検証し空の任意fieldを除く")
  func validatesMetadata() throws {
    let sourceURL = URL(string: "https://example.jp")!
    let image = try #require(
      ChatLinkPreviewImage(resource: " storage/path ", pixelWidth: 1200, pixelHeight: 630)
    )
    let preview = try #require(
      ChatLinkPreview(
        sourceURL: sourceURL,
        title: "表示タイトル",
        description: "  ",
        siteName: "  Example  ",
        image: image
      )
    )

    #expect(preview.title == "表示タイトル")
    #expect(preview.description == nil)
    #expect(preview.siteName == "Example")
    #expect(preview.image?.resource == "storage/path")
  }

  @Test("文字数上限を超えるmetadataを拒否する")
  func rejectsOversizedMetadata() throws {
    let url = URL(string: "https://example.jp")!

    #expect(ChatLinkPreview(sourceURL: url, title: String(repeating: "題", count: 201)) == nil)
    #expect(
      ChatLinkPreview(
        sourceURL: url,
        title: "Title",
        description: String(repeating: "d", count: 501)
      ) == nil
    )
    #expect(
      ChatLinkPreview(
        sourceURL: url,
        title: "Title",
        siteName: String(repeating: "s", count: 101)
      ) == nil
    )
  }

  @Test("空title、不正scheme、不正画像寸法を拒否する")
  func rejectsInvalidValues() throws {
    let httpURL = URL(string: "https://example.jp")!
    let fileURL = URL(filePath: "/tmp/example")

    #expect(ChatLinkPreview(sourceURL: httpURL, title: "  ") == nil)
    #expect(ChatLinkPreview(sourceURL: fileURL, title: "Title") == nil)
    #expect(ChatLinkPreviewImage(resource: "image", pixelWidth: 0, pixelHeight: 100) == nil)
  }

  @Test("既存message initializerではpreviewなしを維持し任意値も保持する")
  func keepsOptionalMessagePreview() throws {
    let url = URL(string: "https://example.jp")!
    let preview = try #require(ChatLinkPreview(sourceURL: url, title: "Example"))
    let legacyMessage = ChatMessage(
      id: "legacy",
      createdAt: .init(timeIntervalSince1970: 0),
      sender: nil,
      content: .text("本文")
    )
    let previewMessage = ChatMessage(
      id: "preview",
      createdAt: .init(timeIntervalSince1970: 0),
      sender: nil,
      content: .text(url.absoluteString),
      linkPreview: preview
    )

    #expect(legacyMessage.linkPreview == nil)
    #expect(previewMessage.linkPreview == preview)
  }

  @Test("submissionは本文がある場合だけdraft previewを保持する")
  func keepsDraftPreviewOnlyWithText() throws {
    let url = URL(string: "https://example.jp")!
    let preview = try #require(ChatLinkPreview(sourceURL: url, title: "Example"))
    let textSubmission = try #require(
      ChatComposerSubmission(text: " https://example.jp ", images: [], linkPreview: preview)
    )
    let imageDraft = ChatImageDraft(id: "image", fileURL: URL(filePath: "/tmp/image.jpg"))
    let imageSubmission = try #require(
      ChatComposerSubmission(text: nil, images: [imageDraft], linkPreview: preview)
    )

    #expect(textSubmission.linkPreview == preview)
    #expect(imageSubmission.linkPreview == nil)
  }
}

private struct LinkPreviewFixture: Decodable {
  let selectionCases: [SelectionCase]

  struct SelectionCase: Decodable {
    let name: String
    let text: String
    let sourceUrl: String?
  }
}
