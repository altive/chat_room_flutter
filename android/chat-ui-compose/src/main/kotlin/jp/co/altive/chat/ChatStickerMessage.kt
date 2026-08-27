package jp.co.altive.chat

import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.CancellationException

/** consumerが検証済みassetから解決したステッカー画像。 */
data class ChatResolvedSticker(
  val imageData: ByteArray,
  val accessibilityLabel: String? = null,
)

/** ステッカー参照を検証済み画像へ解決する処理。 */
fun interface ChatStickerImageLoader {
  suspend fun load(reference: ChatStickerReference): ChatResolvedSticker
}

/** ステッカーメッセージの共通寸法。 */
object ChatStickerMessageMetrics {
  val displayLength = 176.dp
}

private sealed interface ChatStickerImageState {
  data object Loading : ChatStickerImageState
  data class Loaded(val sticker: ChatResolvedSticker, val bitmap: ImageBitmap) : ChatStickerImageState
  data object Failed : ChatStickerImageState
}

/** 読み込み・失敗・再試行を含むステッカーメッセージ本文。 */
@Composable
fun ChatStickerMessageContent(
  reference: ChatStickerReference,
  imageLoader: ChatStickerImageLoader?,
  stickerLabel: String = "Sticker",
  loadingFailureLabel: String = "Failed to load sticker",
  modifier: Modifier = Modifier,
) {
  var retryId by remember(reference) { mutableIntStateOf(0) }
  val state by produceState<ChatStickerImageState>(
    initialValue = ChatStickerImageState.Loading,
    reference,
    imageLoader,
    retryId,
  ) {
    value = if (imageLoader == null) {
      ChatStickerImageState.Failed
    } else {
      try {
        val sticker = imageLoader.load(reference)
        val bitmap = checkNotNull(
          BitmapFactory.decodeByteArray(sticker.imageData, 0, sticker.imageData.size),
        ).asImageBitmap()
        ChatStickerImageState.Loaded(sticker, bitmap)
      } catch (cancellation: CancellationException) {
        throw cancellation
      } catch (_: Throwable) {
        ChatStickerImageState.Failed
      }
    }
  }
  val accessibilityLabel = when (val current = state) {
    ChatStickerImageState.Loading -> stickerLabel
    ChatStickerImageState.Failed -> loadingFailureLabel
    is ChatStickerImageState.Loaded ->
      current.sticker.accessibilityLabel?.takeIf(String::isNotBlank) ?: stickerLabel
  }

  Box(
    modifier = modifier
      .size(ChatStickerMessageMetrics.displayLength)
      .clickable(enabled = state == ChatStickerImageState.Failed) { retryId += 1 }
      .testTag("AltiveChatUI.StickerMessage")
      .semantics { contentDescription = accessibilityLabel },
    contentAlignment = Alignment.Center,
  ) {
    when (val current = state) {
      ChatStickerImageState.Loading -> CircularProgressIndicator()
      ChatStickerImageState.Failed -> Text(loadingFailureLabel)
      is ChatStickerImageState.Loaded -> {
        Image(
          bitmap = current.bitmap,
          contentDescription = null,
          contentScale = ContentScale.Fit,
          modifier = Modifier.fillMaxSize(),
        )
      }
    }
  }
}
