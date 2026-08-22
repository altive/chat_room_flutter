import Testing

@testable import AltiveChatUI

@Suite("チャット入力")
struct ChatComposerTests {
  @Test("前後の空白と改行を除いて送信文字列を作る")
  func normalizesDraft() {
    #expect(ChatDraftPolicy.unrestricted.normalizedText(from: "  Hello\n") == "Hello")
  }

  @Test("空白と改行だけの場合は送信対象を作らない")
  func rejectsBlankDraft() {
    #expect(ChatDraftPolicy.unrestricted.normalizedText(from: " \n\t") == nil)
  }

  @Test("入力欄のフォーカス中だけ添付ボタンを閉じる")
  func controlsLeadingButtonVisibility() {
    #expect(!showsChatComposerSourceButtons(isFocused: true))
    #expect(showsChatComposerSourceButtons(isFocused: false))
  }
}
