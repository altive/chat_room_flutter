package jp.co.altive.chat

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class ChatComposerVisibilityTest {
  @Test fun `入力欄のフォーカス中は展開操作まで添付ボタンを閉じる`() {
    assertFalse(
      shouldShowChatComposerSourceButtons(
        isFocused = true,
        isExpandedWhileFocused = false,
      ),
    )
    assertTrue(
      shouldShowChatComposerSourceButtons(
        isFocused = true,
        isExpandedWhileFocused = true,
      ),
    )
    assertTrue(
      shouldShowChatComposerSourceButtons(
        isFocused = false,
        isExpandedWhileFocused = false,
      ),
    )
  }

  @Test fun `フォーカスを維持したままの展開では添付ボタンを閉じない`() {
    assertFalse(
      shouldCollapseChatComposerSourceButtons(
        wasFocused = true,
        isFocused = true,
      ),
    )
  }

  @Test fun `通常のフォーカス獲得では添付ボタンを閉じる`() {
    assertTrue(
      shouldCollapseChatComposerSourceButtons(
        wasFocused = false,
        isFocused = true,
      ),
    )
  }
}
