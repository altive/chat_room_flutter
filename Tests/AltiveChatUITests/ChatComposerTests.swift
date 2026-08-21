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

  @Test("入力欄のフォーカス中は展開操作まで添付ボタンを閉じる")
  func controlsLeadingButtonVisibility() {
    #expect(!showsChatComposerSourceButtons(isFocused: true, isExpandedWhileFocused: false))
    #expect(showsChatComposerSourceButtons(isFocused: true, isExpandedWhileFocused: true))
    #expect(showsChatComposerSourceButtons(isFocused: false, isExpandedWhileFocused: false))
  }

  @Test("手動展開に伴うフォーカス復元では添付ボタンを閉じない")
  func preservesLeadingButtonsWhileRestoringFocus() {
    #expect(
      !shouldCollapseChatComposerSourceButtons(
        wasFocused: false,
        isFocused: true,
        isRestoringFocusAfterExpansion: true
      )
    )
  }

  @Test("通常のフォーカス獲得では添付ボタンを閉じる")
  func collapsesLeadingButtonsOnRegularFocusGain() {
    #expect(
      shouldCollapseChatComposerSourceButtons(
        wasFocused: false,
        isFocused: true,
        isRestoringFocusAfterExpansion: false
      )
    )
  }
}
