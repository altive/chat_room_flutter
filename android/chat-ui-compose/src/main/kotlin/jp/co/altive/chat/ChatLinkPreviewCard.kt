package jp.co.altive.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import kotlin.coroutines.coroutineContext
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.ensureActive

/** 入力中リンクプレビューの表示状態。 */
sealed interface ChatDraftLinkPreviewState {
  data object None : ChatDraftLinkPreviewState
  data class Loading(val sourceUrl: String) : ChatDraftLinkPreviewState
  data class Loaded(val preview: ChatLinkPreview) : ChatDraftLinkPreviewState
}

/** draftの先頭URLをdebounceして解決し、古い結果を採用しない状態を返す。 */
@Composable
fun rememberChatDraftLinkPreviewState(
  draft: String,
  resolver: (suspend (String) -> ChatLinkPreview?)?,
): ChatDraftLinkPreviewState {
  val sourceUrl = remember(draft) { ChatLinkPreviewParser.firstUrl(draft) }
  val latestResolver by rememberUpdatedState(resolver)
  var state by remember(sourceUrl, resolver != null) {
    mutableStateOf<ChatDraftLinkPreviewState>(
      if (sourceUrl != null && resolver != null) {
        ChatDraftLinkPreviewState.Loading(sourceUrl)
      } else {
        ChatDraftLinkPreviewState.None
      },
    )
  }

  LaunchedEffect(sourceUrl, resolver != null) {
    val requestedUrl = sourceUrl ?: return@LaunchedEffect
    val resolve = latestResolver ?: return@LaunchedEffect
    state = ChatDraftLinkPreviewState.Loading(requestedUrl)
    delay(500)
    try {
      val preview = resolve(requestedUrl)
      coroutineContext.ensureActive()
      state = if (preview?.isDisplayable == true &&
        normalizeChatLinkPreviewUrl(preview.sourceUrl) == requestedUrl
      ) {
        ChatDraftLinkPreviewState.Loaded(preview)
      } else {
        ChatDraftLinkPreviewState.None
      }
    } catch (cancellation: CancellationException) {
      throw cancellation
    } catch (_: Throwable) {
      state = ChatDraftLinkPreviewState.None
    }
  }
  return state
}

/** 現在の本文と一致する解決済みpreviewを送信値として返す。 */
fun ChatDraftLinkPreviewState.previewForSubmission(draft: String): ChatLinkPreview? {
  val preview = (this as? ChatDraftLinkPreviewState.Loaded)?.preview ?: return null
  return preview.takeIf { ChatLinkPreviewParser.firstUrl(draft) == it.sourceUrl }
}

/** 利用アプリが解決したWebリンクプレビューを表示する共通カード。 */
@Composable
fun ChatLinkPreviewCard(
  preview: ChatLinkPreview,
  linkPreviewLabel: String,
  modifier: Modifier = Modifier,
  imageContent: (@Composable BoxScope.(ChatLinkPreviewImage) -> Unit)? = null,
  onOpenLink: ((String) -> Unit)? = null,
) {
  if (!preview.isDisplayable) return
  val context = LocalContext.current
  val openLink = onOpenLink ?: remember(context) { defaultChatLinkOpener(context) }
  val description = preview.description?.trim()?.takeIf(String::isNotEmpty)
  val siteName = preview.siteName?.trim()?.takeIf(String::isNotEmpty)
  val title = preview.title.trim()
  val accessibilityLabel = listOfNotNull(
    linkPreviewLabel,
    siteName,
    title,
    description,
    preview.sourceUrl,
  ).joinToString(". ")
  val shape = RoundedCornerShape(12.dp)

  Column(
    modifier
      .widthIn(max = 300.dp)
      .clip(shape)
      .background(MaterialTheme.colorScheme.surface.copy(alpha = .94f))
      .clickable(role = Role.Button) { openLink(preview.sourceUrl) }
      .semantics(mergeDescendants = true) {
        role = Role.Button
        contentDescription = accessibilityLabel
      }
      .testTag("AltiveChatUI.LinkPreview"),
  ) {
    val image = preview.image
    if (image?.isDisplayable == true && imageContent != null) {
      Box(
        Modifier.fillMaxWidth().height(linkPreviewImageHeight(image))
          .background(MaterialTheme.colorScheme.surfaceContainerHighest),
        contentAlignment = Alignment.Center,
      ) {
        imageContent(image)
      }
    }
    Column(
      Modifier.padding(horizontal = 12.dp, vertical = 10.dp),
      verticalArrangement = Arrangement.spacedBy(3.dp),
    ) {
      if (siteName != null) {
        Text(
          siteName,
          style = MaterialTheme.typography.labelSmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          maxLines = 1,
          overflow = TextOverflow.Ellipsis,
        )
      }
      Text(
        title,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurface,
        fontWeight = FontWeight.SemiBold,
        maxLines = 2,
        overflow = TextOverflow.Ellipsis,
      )
      if (description != null) {
        Text(
          description,
          style = MaterialTheme.typography.bodySmall,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          maxLines = 3,
          overflow = TextOverflow.Ellipsis,
        )
      }
    }
  }
}

@Composable
fun ChatDraftLinkPreview(
  state: ChatDraftLinkPreviewState,
  strings: ChatRoomStrings,
  imageContent: (@Composable BoxScope.(ChatLinkPreviewImage) -> Unit)?,
  onOpenLink: ((String) -> Unit)?,
) {
  when (state) {
    ChatDraftLinkPreviewState.None -> Unit
    is ChatDraftLinkPreviewState.Loading -> Box(
      Modifier.fillMaxWidth().height(76.dp)
        .background(MaterialTheme.colorScheme.surfaceContainerHighest, RoundedCornerShape(12.dp))
        .semantics { contentDescription = strings.linkPreviewLoadingLabel }
        .testTag("AltiveChatUI.LinkPreviewLoading"),
    )
    is ChatDraftLinkPreviewState.Loaded -> ChatLinkPreviewCard(
      preview = state.preview,
      linkPreviewLabel = strings.linkPreviewLabel,
      modifier = Modifier.fillMaxWidth(),
      imageContent = imageContent,
      onOpenLink = onOpenLink,
    )
  }
}

private fun linkPreviewImageHeight(image: ChatLinkPreviewImage) =
  (300f / (image.aspectRatio ?: (1.91f))).dp.coerceIn(100.dp, 180.dp)
