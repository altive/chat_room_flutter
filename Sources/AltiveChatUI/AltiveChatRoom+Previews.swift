#if DEBUG
  import Foundation
  import SwiftUI

  @MainActor
  private struct AltiveChatRoomPreview: View {
    @State private var draft = "https://altive.dev"

    private let me = ChatUser(id: "me", displayName: "Me")
    private let other = ChatUser(id: "other", displayName: "Altive")
    private let previewImageData = Data(
      base64Encoded:
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )!

    private var linkPreview: ChatLinkPreview {
      ChatLinkPreview(
        sourceURL: URL(string: "https://altive.dev")!,
        title: "Altive",
        description: "プロダクト開発に関する情報を紹介します。",
        siteName: "altive.dev",
        image: ChatLinkPreviewImage(
          resource: "preview/altive.webp",
          pixelWidth: 1200,
          pixelHeight: 630
        )!
      )!
    }

    var body: some View {
      AltiveChatRoom(
        messages: [
          .init(
            id: "system",
            createdAt: .init(timeIntervalSince1970: 1_700_000_000),
            sender: nil,
            content: .system("Conversation started")
          ),
          .init(
            id: "incoming",
            createdAt: .init(timeIntervalSince1970: 1_700_000_060),
            sender: other,
            content: .text("https://altive.dev を確認してください"),
            linkPreview: linkPreview
          ),
          .init(
            id: "outgoing",
            createdAt: .init(timeIntervalSince1970: 1_700_000_120),
            sender: me,
            content: .text("Hello, Altive!"),
            deliveryState: .sending
          ),
        ],
        currentUserID: me.id,
        draft: $draft,
        showsSenderName: true,
        linkPreviewResolver: { url in
          ChatLinkPreview(
            sourceURL: url,
            title: "入力中の固定プレビュー",
            description: "外部networkへ接続しないPreview用fixtureです。",
            siteName: "altive.dev",
            image: ChatLinkPreviewImage(
              resource: "preview/altive.webp",
              pixelWidth: 1200,
              pixelHeight: 630
            )!
          )
        },
        linkPreviewImageLoader: ChatLinkPreviewImageLoader { _ in previewImageData },
        onSend: { _ in }
      )
    }
  }

  @MainActor
  private struct AltiveChatImageRoomPreview: View {
    @State private var draft = "画像と一緒に送れます"
    @State private var imageDrafts: [ChatImageDraft] = []

    private let me = ChatUser(id: "me", displayName: "Me")
    private let previewImageData = Data(
      base64Encoded:
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )!

    var body: some View {
      AltiveChatRoom(
        messages: [
          .init(
            id: "images",
            createdAt: .init(timeIntervalSince1970: 1_700_000_120),
            sender: me,
            content: .images(
              (0..<5).map { index in
                ChatImage(
                  id: "preview-\(index)",
                  resource: .remote(URL(string: "https://example.com/\(index).png")!),
                  pixelWidth: 600,
                  pixelHeight: 600,
                  accessibilityLabel: "Preview image \(index + 1)"
                )
              }
            )
          )
        ],
        currentUserID: me.id,
        draft: $draft,
        imageDrafts: $imageDrafts,
        imageInputConfiguration: .init(),
        imageLoader: ChatImageLoader { _ in previewImageData },
        onRequestCamera: {},
        resolvePhotoLibraryItem: { _ in
          throw CocoaError(.fileReadUnknown)
        },
        onSubmit: { _ in }
      )
    }
  }

  #Preview("Messages") {
    AltiveChatRoomPreview()
  }

  #Preview("Empty") {
    AltiveChatRoom(
      messages: [],
      currentUserID: "me",
      draft: .constant(""),
      onSend: { _ in }
    )
  }

  #Preview("Images") {
    AltiveChatImageRoomPreview()
  }
#endif
