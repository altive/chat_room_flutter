package jp.co.altive.chat

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class ChatComposerVisibilityTest {
  @Test fun `入力欄のフォーカス中だけ添付ボタンを閉じる`() {
    assertFalse(
      shouldShowChatComposerSourceButtons(
        isFocused = true,
      ),
    )
    assertTrue(
      shouldShowChatComposerSourceButtons(
        isFocused = false,
      ),
    )
  }
}
