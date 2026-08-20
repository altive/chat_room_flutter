import SwiftUI
import Testing

@testable import AltiveChatUI

@Suite("汎用メッセージカード")
@MainActor
struct ChatMessageCardTests {
  @Test("footerなしのcelebrationカードを構築できる")
  func createsCelebrationCardWithoutFooter() {
    let card = ChatMessageCard(
      style: .celebration,
      isOwnMessage: false,
      accessibilityLabel: "お祝いカード"
    ) {
      Text("おめでとう")
    } content: {
      Text("すてきな一年になりますように")
    }

    _ = card.body
  }

  @Test("footer付きのcelebrationカードを構築できる")
  func createsCelebrationCardWithFooter() {
    let card = ChatMessageCard(
      style: .celebration,
      isOwnMessage: true,
      accessibilityLabel: "お祝いカード"
    ) {
      Text("おめでとう")
    } content: {
      Text("すてきな一年になりますように")
    } footer: {
      Text("補足")
    }

    _ = card.body
  }
}
