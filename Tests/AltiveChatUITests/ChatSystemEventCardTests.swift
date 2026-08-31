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

  @Test("短い内容幅を維持して長い内容を利用可能幅で制限する")
  func capsCompactCenteredWidthAtAvailableWidth() {
    #expect(
      ChatSystemEventCardLayoutMetrics.compactCardWidth(
        idealWidth: 180,
        availableWidth: 320
      ) == 180
    )
    #expect(
      ChatSystemEventCardLayoutMetrics.compactCardWidth(
        idealWidth: 480,
        availableWidth: 320
      ) == 320
    )
  }

  @Test("内容幅のカードを利用可能幅の中央へ配置する")
  func centersCompactCardWithinAvailableWidth() {
    #expect(
      ChatSystemEventCardLayoutMetrics.centeredOriginX(
        containerWidth: 320,
        cardWidth: 180
      ) == 70
    )
  }

  @Test("非有限の提案幅と理想幅を有限のレイアウト幅へ正規化する")
  func normalizesNonFiniteWidths() {
    #expect(
      ChatSystemEventCardLayoutMetrics.availableWidth(
        proposedWidth: .infinity,
        idealWidth: 180
      ) == 180
    )
    #expect(
      ChatSystemEventCardLayoutMetrics.availableWidth(
        proposedWidth: .infinity,
        idealWidth: .infinity
      ) == 0
    )
    #expect(
      ChatSystemEventCardLayoutMetrics.compactCardWidth(
        idealWidth: .infinity,
        availableWidth: 320
      ) == 320
    )
    #expect(
      ChatSystemEventCardLayoutMetrics.compactCardWidth(
        idealWidth: 180,
        availableWidth: .infinity
      ) == 180
    )
  }
}
