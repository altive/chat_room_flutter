package jp.co.altive.chat

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.dp
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ChatImageGridTest {
  @get:Rule val compose = createComposeRule()

  @Test
  fun `先頭横長配置では3枚の先頭画像を全幅にする`() {
    compose.setContent {
      MaterialTheme {
        ChatImageGrid(
          messageId = "message",
          images = testImages(),
          imageLabel = "画像",
          multipleImageLayout = ChatMultipleImageLayout.LeadingWideGrid,
        )
      }
    }

    val firstWidth = compose.onNodeWithContentDescription("画像1")
      .fetchSemanticsNode().boundsInRoot.width
    val secondWidth = compose.onNodeWithContentDescription("画像2")
      .fetchSemanticsNode().boundsInRoot.width

    assertTrue(firstWidth > secondWidth * 1.9f)
  }

  @Test
  fun `Mosaic配置では3枚の先頭画像を左側で大きくする`() {
    compose.setContent {
      MaterialTheme {
        ChatImageGrid(
          messageId = "message",
          images = testImages(),
          imageLabel = "画像",
          multipleImageLayout = ChatMultipleImageLayout.Mosaic,
        )
      }
    }

    val firstWidth = compose.onNodeWithContentDescription("画像1")
      .fetchSemanticsNode().boundsInRoot.width
    val secondWidth = compose.onNodeWithContentDescription("画像2")
      .fetchSemanticsNode().boundsInRoot.width

    assertTrue(firstWidth > secondWidth * 1.9f)
  }

  @Test
  fun `4枚超は2掛ける2へ収めて超過件数を表示する`() {
    compose.setContent {
      MaterialTheme {
        ChatImageGrid(
          messageId = "message",
          images = testImages(5),
          imageLabel = "画像",
        )
      }
    }

    compose.onNodeWithText("+1").assertIsDisplayed()
  }

  @Test
  fun `単一画像は可変比率を既定とし正方形も選べる`() {
    val image = ChatImage(
      id = "image-1",
      resource = ChatImageResource.RemoteUrl("https://example.com/image-1"),
      pixelWidth = 400,
      pixelHeight = 800,
    )

    assertEquals(260.dp, singleImageHeight(image, ChatSingleImageLayout.AdaptiveBounded()))
    assertEquals(240.dp, singleImageHeight(image, ChatSingleImageLayout.Square))
  }

  @Test
  fun `同じ画像IDのremote切替では準備完了までlocal画像を渡す`() {
    var image by mutableStateOf(
      ChatImage("image-1", ChatImageResource.LocalUri("content://image-1")),
    )
    var observedTransition: ChatImageContentTransition? = null
    compose.setContent {
      MaterialTheme {
        ChatImageGrid(
          messageId = "message",
          images = listOf(image),
          imageLabel = "画像",
          transitioningImageContent = { transition ->
            observedTransition = transition
            Box(Modifier.fillMaxSize()) {
              Button(
                onClick = transition.onImageReady,
                modifier = Modifier.fillMaxSize(),
              ) { Text("準備完了") }
            }
          },
        )
      }
    }

    compose.runOnIdle {
      assertNull(observedTransition?.previousImage)
      image = image.copy(resource = ChatImageResource.RemoteUrl("https://example.com/image-1"))
    }
    compose.waitForIdle()
    compose.runOnIdle {
      val previous = observedTransition?.previousImage
      assertNotNull(previous)
      assertEquals(ChatImageResource.LocalUri("content://image-1"), previous?.resource)
    }

    compose.onNodeWithText("準備完了").performClick()
    compose.waitForIdle()
    compose.runOnIdle { assertNull(observedTransition?.previousImage) }
  }

  private fun testImages(count: Int = 3): List<ChatImage> = (1..count).map { index ->
    ChatImage(
      id = "image-$index",
      resource = ChatImageResource.RemoteUrl("https://example.com/image-$index"),
      accessibilityLabel = "画像$index",
    )
  }
}
