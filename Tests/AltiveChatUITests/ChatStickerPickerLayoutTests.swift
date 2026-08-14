#if canImport(AppKit)
  import AppKit
  import SwiftUI
  import Testing

  @testable import AltiveChatUI

  @Suite("ステッカーpickerのレイアウト")
  @MainActor
  struct ChatStickerPickerLayoutTests {
    @Test("末尾コンテンツをスタンプ一覧へ重ねない")
    func keepsFooterBelowStickerGrid() throws {
      let stickers = (0..<24).map { index in
        ChatStickerPickerItem(
          id: String(index),
          reference: index,
          asset: index,
          accessibilityLabel: "スタンプ\(index)"
        )
      }
      let pack = ChatStickerPickerPack(
        id: "pack",
        displayName: "パック",
        trayIcon: -1,
        stickers: stickers
      )
      let picker = ChatStickerPicker(
        isCatalogLoading: false,
        isCatalogAvailable: true,
        loadState: .loaded,
        packs: [pack],
        selectedPackID: pack.id,
        isHistorySelected: false,
        recentReferences: [],
        strings: ChatStickerPickerStrings(
          historyLabel: "履歴",
          historyEmptyTitle: "履歴なし",
          unavailableTitle: "利用不可",
          failedTitle: "取得失敗",
          retryLabel: "再試行"
        ),
        onSelectHistory: {},
        onSelectPack: { _ in },
        onSelect: { _ in },
        onRetry: {},
        footer: {
          Color(red: 0, green: 0, blue: 1)
            .frame(height: 60)
        },
        image: { _ in
          Color(red: 1, green: 0, blue: 0)
            .frame(width: 88, height: 88)
        }
      )
      .frame(width: 390, height: 300)

      let renderer = ImageRenderer(content: picker)
      renderer.scale = 1
      let image = try #require(renderer.cgImage)
      let bitmap = NSBitmapImageRep(cgImage: image)

      var footerPixelCount = 0
      for y in 70..<bitmap.pixelsHigh {
        for x in 0..<bitmap.pixelsWide {
          guard let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else {
            continue
          }
          if color.blueComponent > 0.9,
            color.redComponent < 0.1,
            color.greenComponent < 0.1
          {
            footerPixelCount += 1
          }
        }
      }

      #expect(footerPixelCount == 0)
    }
  }
#endif
