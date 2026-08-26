import Testing

@testable import AltiveChatCore

@Suite("チャット状態")
struct ChatStateTests {
  @Test("失敗した送信だけを再送中へ戻す")
  func retriesFailedDelivery() {
    var delivery = ChatDeliveryStateMachine(state: .failed)
    let didBeginRetry = delivery.beginRetry()
    #expect(didBeginRetry)
    #expect(delivery.state == .sending)
    let didRetryTwice = delivery.beginRetry()
    #expect(!didRetryTwice)
    delivery.markSent()
    #expect(delivery.state == .sent)
  }

  @Test("送信状態を更新して再送してもメッセージIDを維持する")
  func preservesMessageIDAcrossRetry() {
    let sender = ChatUser(id: "me", displayName: "Me")
    let failed = ChatMessage(
      id: "stable-message-id",
      createdAt: .init(timeIntervalSince1970: 1_700_000_000),
      sender: sender,
      content: .text("再送する本文"),
      deliveryState: .failed
    )
    let retrying = ChatMessage(
      id: failed.id,
      createdAt: failed.createdAt,
      sender: failed.sender,
      content: failed.content,
      deliveryState: .sending
    )

    #expect(retrying.id == failed.id)
    #expect(retrying.deliveryState == .sending)
  }

  @Test("最近利用した値を先頭へ移し重複と上限を除く")
  func updatesRecentItems() {
    #expect(ChatRecentItems.updating(["a", "b", "c"], adding: "b", limit: 2) == ["b", "a"])
    #expect(ChatRecentItems.updating(["a"], adding: "b", limit: 0).isEmpty)
  }
}
