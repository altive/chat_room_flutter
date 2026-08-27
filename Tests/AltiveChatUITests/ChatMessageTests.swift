import Foundation
import Testing

@testable import AltiveChatUI

@Suite("チャットメッセージ")
struct ChatMessageTests {
  @Test("指定したユーザーが送信者の場合だけ自分のメッセージとして扱う")
  func identifiesSender() {
    let sender = ChatUser(id: "me", displayName: "Me")
    let message = ChatMessage(
      id: "message",
      createdAt: .init(timeIntervalSince1970: 1_700_000_000),
      sender: sender,
      content: .text("Hello")
    )

    #expect(message.isSent(by: "me"))
    #expect(!message.isSent(by: "other"))
  }

  @Test("システムメッセージは送信者なしで作成できる")
  func createsSystemMessageWithoutSender() {
    let message = ChatMessage(
      id: "system",
      createdAt: .init(timeIntervalSince1970: 1_700_000_000),
      sender: nil,
      content: .system("Joined")
    )

    #expect(message.sender == nil)
    #expect(message.content == .system("Joined"))
  }

  @Test("構造化ステッカー参照をメッセージ内容として保持する")
  func keepsStickerReference() {
    let reference = ChatStickerReference(
      packID: "standard",
      stickerID: "thanks",
      locale: "ja",
      assetRevision: 3
    )
    let message = ChatMessage(
      id: "sticker",
      createdAt: .init(timeIntervalSince1970: 1_700_000_000),
      sender: ChatUser(id: "me", displayName: "Me"),
      content: .sticker(reference)
    )

    #expect(message.content == .sticker(reference))
  }
}
