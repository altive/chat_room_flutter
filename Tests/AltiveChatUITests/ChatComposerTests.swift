import Testing
@testable import AltiveChatUI

@Suite("チャット入力")
struct ChatComposerTests {
  @Test("前後の空白と改行を除いて送信文字列を作る")
  func normalizesDraft() {
    #expect(ChatComposer.normalizedText(from: "  Hello\n") == "Hello")
  }

  @Test("空白と改行だけの場合は送信対象を作らない")
  func rejectsBlankDraft() {
    #expect(ChatComposer.normalizedText(from: " \n\t") == nil)
  }
}
