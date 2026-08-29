import AltiveChatCore
import Foundation
import Testing

@testable import AltiveChatUI

@MainActor
struct ChatReplyConfigurationTests {
  @Test("App固有変換ではpackage標準条件を迂回できない")
  func preservesStandardEligibility() {
    let sender = ChatUser(id: "user", displayName: "送信者")
    let sending = ChatMessage(
      id: "sending",
      createdAt: Date(),
      sender: sender,
      content: .text("送信中"),
      deliveryState: .sending
    )
    let reference = ChatReplyReference(
      messageID: "sending",
      senderID: sender.id,
      senderDisplayName: sender.displayName,
      content: .label("カスタム")
    )
    let configuration = ChatReplyConfiguration(makeReference: { _, _ in reference })

    #expect(configuration.reference(for: sending) == nil)
  }

  @Test("App固有条件で送信済みメッセージを返信対象外にできる")
  func appliesApplicationRestriction() {
    let message = ChatMessage(
      id: "sent",
      createdAt: Date(),
      sender: ChatUser(id: "user", displayName: "送信者"),
      content: .text("本文")
    )
    let configuration = ChatReplyConfiguration(canReply: { _ in false })

    #expect(configuration.reference(for: message) == nil)
  }
}
