import Foundation
import Testing

@testable import AltiveChatUI

@Suite("チャット入力面のレイアウト")
struct ChatInputSurfaceGeometryTests {
  @Test("キーボードとウインドウの重なりから安全領域を除く")
  func calculatesKeyboardContentHeight() {
    let height = ChatInputSurfaceGeometry.keyboardContentHeight(
      keyboardEndFrame: CGRect(x: 0, y: 500, width: 390, height: 344),
      windowBounds: CGRect(x: 0, y: 0, width: 390, height: 844),
      bottomSafeAreaInset: 34
    )

    #expect(height == 310)
  }

  @Test("入力面からタブバーなどの下部UIを除く")
  func calculatesInputSurfaceHeight() {
    #expect(
      ChatInputSurfaceGeometry.inputSurfaceHeight(
        keyboardContentHeight: 310,
        bottomChromeHeight: 49
      ) == 261
    )
  }

  @Test("画面外のキーボードや過大な下部UIでは負数を返さない")
  func clampsHeightsToZero() {
    #expect(
      ChatInputSurfaceGeometry.keyboardContentHeight(
        keyboardEndFrame: CGRect(x: 0, y: 900, width: 390, height: 300),
        windowBounds: CGRect(x: 0, y: 0, width: 390, height: 844),
        bottomSafeAreaInset: 34
      ) == 0
    )
    #expect(
      ChatInputSurfaceGeometry.inputSurfaceHeight(
        keyboardContentHeight: 40,
        bottomChromeHeight: 49
      ) == 0
    )
  }

  @Test("inline写真一覧は拡張時だけ利用可能高の約8割まで広がる")
  func calculatesPhotoLibraryHeight() {
    #expect(
      ChatInputSurfaceGeometry.photoLibraryHeight(
        availableHeight: 800,
        isExpanded: false
      ) == 288
    )
    #expect(
      ChatInputSurfaceGeometry.photoLibraryHeight(
        availableHeight: 800,
        isExpanded: true
      ) == 624
    )
  }

  @Test("低い画面ではinline写真一覧を利用可能高へ収める")
  func clampsPhotoLibraryHeight() {
    #expect(
      ChatInputSurfaceGeometry.photoLibraryHeight(
        availableHeight: 100,
        isExpanded: false
      ) == 100
    )
    #expect(
      ChatInputSurfaceGeometry.photoLibraryHeight(
        availableHeight: -1,
        isExpanded: true
      ) == 0
    )
  }
}
