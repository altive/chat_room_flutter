package jp.co.altive.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage

/** Roomで返信を開始・表示するための設定。 */
class ChatReplyConfiguration(
  private val canReply: (ChatMessage) -> Boolean = { true },
  private val makeReference: (ChatMessage, Int?) -> ChatReplyReference? =
    { message, imageIndex -> ChatReplyReference.from(message, imageIndex) },
  val onReferenceTap: ((messageId: String, imageIndex: Int?) -> Unit)? = null,
) {
  /** package既定条件とapp固有条件を満たす返信参照を返す。 */
  fun referenceFor(message: ChatMessage, imageIndex: Int? = null): ChatReplyReference? =
    if (message.isStandardReplyTarget() && canReply(message)) {
      makeReference(message, imageIndex)
    } else {
      null
    }
}

private fun ChatMessage.isStandardReplyTarget(): Boolean =
  deliveryState == ChatMessageDeliveryState.Sent &&
    sender != null &&
    content !is ChatMessageContent.System

/** メッセージ内へ表示する返信元の引用。 */
@Composable
fun ChatReplyQuote(
  reference: ChatReplyReference,
  strings: ChatRoomStrings = ChatRoomStrings.localized(),
  modifier: Modifier = Modifier,
  stickerImageLoader: ChatStickerImageLoader? = null,
  onTap: (() -> Unit)? = null,
) {
  val previewText = when (val content = reference.content) {
    is ChatReplyPreviewContent.Text -> content.value
    is ChatReplyPreviewContent.Image ->
      content.caption?.takeIf(String::isNotBlank) ?: "${strings.imageLabel} ${content.totalCount}"
    is ChatReplyPreviewContent.Sticker -> strings.stickerLabel
    is ChatReplyPreviewContent.Label -> content.value
    ChatReplyPreviewContent.Unavailable -> strings.replyUnavailableLabel
  }
  Row(
    modifier = modifier
      .fillMaxWidth()
      .clip(RoundedCornerShape(9.dp))
      .background(MaterialTheme.colorScheme.onSurface.copy(alpha = .08f))
      .clickable(enabled = onTap != null) { onTap?.invoke() }
      .semantics {
        contentDescription =
          "${strings.replyToLabel}, ${reference.senderDisplayName}, $previewText"
      }
      .padding(8.dp),
    horizontalArrangement = Arrangement.spacedBy(8.dp),
    verticalAlignment = Alignment.CenterVertically,
  ) {
    Box(
      Modifier.width(3.dp).height(44.dp)
        .background(MaterialTheme.colorScheme.onSurfaceVariant),
    )
    Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
      Text(
        reference.senderDisplayName,
        style = MaterialTheme.typography.labelMedium,
        fontWeight = FontWeight.Bold,
        maxLines = 1,
        overflow = TextOverflow.Ellipsis,
      )
      Text(
        previewText,
        style = MaterialTheme.typography.labelMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        maxLines = 2,
        overflow = TextOverflow.Ellipsis,
      )
    }
    when (val content = reference.content) {
      is ChatReplyPreviewContent.Image -> content.thumbnail?.let { image ->
        AsyncImage(
          model = image.resource.replyModelValue(),
          contentDescription = image.accessibilityLabel ?: strings.imageLabel,
          modifier = Modifier.size(44.dp).clip(RoundedCornerShape(6.dp)),
        )
      }
      is ChatReplyPreviewContent.Sticker -> ChatStickerMessageContent(
        reference = content.reference,
        imageLoader = stickerImageLoader,
        stickerLabel = strings.stickerLabel,
        loadingFailureLabel = strings.stickerLoadingFailedLabel,
        displayLength = 44.dp,
      )
      else -> Unit
    }
  }
}

/** Composer上部へ表示する選択中の返信元。 */
@Composable
fun ChatReplyComposerBar(
  reference: ChatReplyReference,
  onCancel: () -> Unit,
  strings: ChatRoomStrings = ChatRoomStrings.localized(),
  modifier: Modifier = Modifier,
  stickerImageLoader: ChatStickerImageLoader? = null,
) {
  Row(
    modifier.fillMaxWidth().padding(start = 16.dp, top = 8.dp, end = 8.dp),
    verticalAlignment = Alignment.CenterVertically,
  ) {
    ChatReplyQuote(
      reference = reference,
      strings = strings,
      modifier = Modifier.weight(1f),
      stickerImageLoader = stickerImageLoader,
    )
    IconButton(
      onClick = onCancel,
      modifier = Modifier.semantics { contentDescription = strings.cancelReplyLabel },
    ) { Text("×") }
  }
}

private fun ChatImageResource.replyModelValue(): String = when (this) {
  is ChatImageResource.LocalUri -> value
  is ChatImageResource.RemoteUrl -> value
}
