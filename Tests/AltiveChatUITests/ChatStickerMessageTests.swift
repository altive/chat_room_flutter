import Foundation
import Testing

@testable import AltiveChatUI

struct ChatStickerMessageTests {
  @Test("consumerのasset解決結果を返す")
  func resolvesStickerData() async throws {
    let reference = ChatStickerReference(
      packID: "standard",
      stickerID: "thanks",
      locale: "ja",
      assetRevision: 3
    )
    let loader = ChatStickerImageLoader { receivedReference in
      #expect(receivedReference == reference)
      return ChatResolvedSticker(
        imageData: Data([0x01, 0x02]),
        accessibilityLabel: "ありがとう"
      )
    }

    let sticker = try await loader.sticker(for: reference)

    #expect(sticker.imageData == Data([0x01, 0x02]))
    #expect(sticker.accessibilityLabel == "ありがとう")
  }

  @Test("タイムラインのステッカー寸法を共通化する")
  func usesStandardDisplayLength() {
    #expect(ChatStickerMessageMetrics.displayLength == 176)
  }
}
