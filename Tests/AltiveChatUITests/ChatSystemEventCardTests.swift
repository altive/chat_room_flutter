import SwiftUI
import Testing

@testable import AltiveChatUI

@Suite("システムイベントカード")
@MainActor
struct ChatSystemEventCardTests {
  @Test("内容幅で中央配置するカードを既存APIで構築できる")
  func createsCompactCenteredCardWithExistingAPI() {
    let card = ChatSystemEventCard {
      Text("システムメッセージ")
    }

    _ = card.body
  }

  @Test("内容幅で中央配置するグループを既存APIで構築できる")
  func createsCompactCenteredGroupWithExistingAPI() {
    let group = ChatSystemEventGroup(
      items: [
        ChatSystemEventItem(
          id: "event",
          occurredAt: Date(timeIntervalSince1970: 1_700_000_000),
          message: "在庫数が変わりました"
        )
      ]
    ) {
      Text("在庫数が変わりました")
    }

    _ = group.body
  }

}
