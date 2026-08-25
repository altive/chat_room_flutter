package jp.co.altive.chat

import androidx.compose.ui.unit.dp
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse

class ChatStickerPickerTest {
  @Test fun `狭い画面でもスタンプを4列表示する`() {
    assertEquals(4, chatStickerColumnCount(390.dp))
    assertEquals(0.5f, chatStickerScale(36.dp))
  }

  @Test fun `横幅に余裕がある場合はスタンプの列数を増やす`() {
    assertEquals(8, chatStickerColumnCount(834.dp))
  }

  @Test fun `既存packはロックされずロック中は読み上げ文を補足する`() {
    val pack = ChatStickerPickerPack(
      id = "pack",
      displayName = "パック",
      trayIcon = Unit,
      stickers = emptyList<ChatStickerPickerItem<Unit, Unit>>(),
    )

    assertFalse(pack.isLocked)
    assertEquals("パック", accessibilityDescription("パック", false, "Premiumで利用できます"))
    assertEquals(
      "パック, Premiumで利用できます",
      accessibilityDescription("パック", true, "Premiumで利用できます"),
    )
  }
}
