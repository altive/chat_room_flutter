package jp.co.altive.chat

import androidx.compose.ui.unit.dp
import kotlin.test.Test
import kotlin.test.assertEquals

class ChatStickerPickerTest {
  @Test fun `狭い画面でもスタンプを4列表示する`() {
    assertEquals(4, ChatStickerPickerColumnCount)
    assertEquals(0.5f, chatStickerScale(36.dp))
  }
}
