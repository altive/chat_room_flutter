import Foundation
import Testing

@testable import AltiveChatCore

struct ChatReplyTests {
  private let sender = ChatUser(id: "user-1", displayName: "送信者")

  @Test
  func テキストメッセージを非再帰の返信参照へ変換する() throws {
    let nested = ChatReplyReference(
      messageID: "older",
      senderID: "user-2",
      senderDisplayName: "別の送信者",
      content: .text("古い本文")
    )
    let message = ChatMessage(
      id: "message-1",
      createdAt: .distantPast,
      sender: sender,
      content: .text("本文"),
      replyTo: nested
    )

    let reference = try #require(ChatReplyReference(message: message))

    #expect(reference.messageID == "message-1")
    #expect(reference.senderID == sender.id)
    #expect(reference.senderDisplayName == sender.displayName)
    #expect(reference.content == .text("本文"))
    #expect(reference.imageIndex == nil)
  }

  @Test
  func 特定画像のindexとthumbnailを正規化する() throws {
    let images = [
      ChatImage(id: "image-1", resource: .remote(URL(string: "https://example.com/1")!)),
      ChatImage(id: "image-2", resource: .remote(URL(string: "https://example.com/2")!)),
    ]
    let message = ChatMessage(
      id: "message-1",
      createdAt: .distantPast,
      sender: sender,
      content: .imagesWithCaption(images: images, caption: "説明")
    )

    let selected = try #require(ChatReplyReference(message: message, imageIndex: 1))
    #expect(selected.imageIndex == 1)
    #expect(selected.content == .image(thumbnail: images[1], caption: "説明", totalCount: 2))

    let fallback = try #require(ChatReplyReference(message: message, imageIndex: 9))
    #expect(fallback.imageIndex == nil)
    #expect(fallback.content == .image(thumbnail: images[0], caption: "説明", totalCount: 2))
  }

  @Test
  func systemと未送信メッセージは返信対象外にする() {
    let system = ChatMessage(
      id: "system",
      createdAt: .distantPast,
      sender: nil,
      content: .system("参加しました")
    )
    let sending = ChatMessage(
      id: "sending",
      createdAt: .distantPast,
      sender: sender,
      content: .text("送信中"),
      deliveryState: .sending
    )

    #expect(ChatReplyReference(message: system) == nil)
    #expect(ChatReplyReference(message: sending) == nil)
  }

  @Test
  func submissionへ返信参照を保持する() throws {
    let reference = ChatReplyReference(
      messageID: "target",
      senderID: sender.id,
      senderDisplayName: sender.displayName,
      content: .text("返信元")
    )

    let submission = try #require(
      ChatComposerSubmission(text: "返信", images: [], replyTo: reference)
    )
    #expect(submission.replyTo == reference)
    #expect(ChatComposerSubmission(text: " ", images: [], replyTo: reference) == nil)
  }
}
