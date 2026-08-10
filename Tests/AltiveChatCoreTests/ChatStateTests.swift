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

  @Test("最近利用した値を先頭へ移し重複と上限を除く")
  func updatesRecentItems() {
    #expect(ChatRecentItems.updating(["a", "b", "c"], adding: "b", limit: 2) == ["b", "a"])
    #expect(ChatRecentItems.updating(["a"], adding: "b", limit: 0).isEmpty)
  }
}
