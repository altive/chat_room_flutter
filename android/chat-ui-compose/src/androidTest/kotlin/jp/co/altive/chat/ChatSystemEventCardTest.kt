package jp.co.altive.chat

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ChatSystemEventCardTest {
  @get:Rule val compose = createComposeRule()

  @Test
  fun `短いシステムイベントカードは内容幅で左右中央に配置する`() {
    compose.setContent {
      MaterialTheme {
        Box(Modifier.width(320.dp)) {
          ChatSystemEventGroup(
            items = items,
            summary = { Text("短い通知") },
          )
        }
      }
    }

    val laneBounds = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_LANE_TAG)
      .fetchSemanticsNode().boundsInRoot
    val cardBounds = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_CARD_TAG)
      .fetchSemanticsNode().boundsInRoot

    assertEquals(laneBounds.center.x, cardBounds.center.x, 1f)
    assertTrue(cardBounds.width < laneBounds.width)
  }

  @Test
  fun `複数イベントの操作領域を48dp以上に保ちながら上下余白を抑える`() {
    compose.setContent {
      MaterialTheme {
        Box(Modifier.width(320.dp)) {
          ChatSystemEventGroup(
            items = items,
            summary = { Text("短い通知") },
          )
        }
      }
    }

    val cardHeight = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_CARD_TAG)
      .fetchSemanticsNode().boundsInRoot.height
    val buttonHeight = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_EXPAND_BUTTON_TAG)
      .fetchSemanticsNode().boundsInRoot.height

    assertTrue(cardHeight <= with(compose.density) { 58.dp.toPx() })
    assertTrue(buttonHeight >= with(compose.density) { 48.dp.toPx() })
  }

  @Test
  fun `長い内容は利用可能幅を超えない`() {
    compose.setContent {
      MaterialTheme {
        Box(Modifier.width(320.dp)) {
          ChatSystemEventCard {
            Text("とても長いシステムメッセージ".repeat(20))
          }
        }
      }
    }

    val laneWidth = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_LANE_TAG)
      .fetchSemanticsNode().boundsInRoot.width
    val cardWidth = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_CARD_TAG)
      .fetchSemanticsNode().boundsInRoot.width

    assertTrue(cardWidth <= laneWidth)
  }

  @Test
  fun `要約へ中央揃えを継承しactionは先頭揃えに戻す`() {
    var summaryTextAlign: TextAlign? = null
    var actionTextAlign: TextAlign? = null
    compose.setContent {
      MaterialTheme {
        ChatSystemEventGroup(
          items = items,
          summary = {
            summaryTextAlign = LocalTextStyle.current.textAlign
            Text("中央揃え")
          },
          actions = {
            actionTextAlign = LocalTextStyle.current.textAlign
            Text("先頭揃え")
          },
        )
      }
    }

    compose.runOnIdle {
      assertEquals(TextAlign.Center, summaryTextAlign)
      assertEquals(TextAlign.Start, actionTextAlign)
    }
  }

  @Test
  fun `明示的な全幅modifierはカード本体へ適用する`() {
    compose.setContent {
      MaterialTheme {
        Box(Modifier.width(320.dp)) {
          ChatSystemEventCard(modifier = Modifier.fillMaxWidth()) {
            Text("全幅通知")
          }
        }
      }
    }

    val laneWidth = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_LANE_TAG)
      .fetchSemanticsNode().boundsInRoot.width
    val cardWidth = compose.onNodeWithTag(CHAT_SYSTEM_EVENT_CARD_TAG)
      .fetchSemanticsNode().boundsInRoot.width

    assertEquals(laneWidth, cardWidth, 1f)
  }

  private companion object {
    val items = listOf(
      ChatSystemEventItem("event-1", 1L, "1件目"),
      ChatSystemEventItem("event-2", 2L, "2件目"),
    )
  }
}
