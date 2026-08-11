package jp.co.altive.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.Dp
import java.text.DateFormat
import java.util.Date

@Immutable
data class ChatRoomStrings(
  val emptyMessage: String,
  val messagePlaceholder: String,
  val sendButtonLabel: String,
  val sendingLabel: String,
  val failedLabel: String,
  val unknownSender: String,
) {
  companion object {
    @Composable fun localized(): ChatRoomStrings {
      return ChatRoomStrings(
        stringResource(R.string.altive_chat_empty),
        stringResource(R.string.altive_chat_placeholder),
        stringResource(R.string.altive_chat_send),
        stringResource(R.string.altive_chat_sending),
        stringResource(R.string.altive_chat_failed),
        stringResource(R.string.altive_chat_unknown_sender),
      )
    }
  }
}

@Composable
fun AltiveChatRoom(
  messages: List<ChatMessage>,
  currentUserId: String,
  draft: String,
  onDraftChange: (String) -> Unit,
  modifier: Modifier = Modifier,
  theme: ChatRoomTheme = ChatRoomTheme.standard(),
  strings: ChatRoomStrings = ChatRoomStrings.localized(),
  showsSenderName: Boolean = false,
  draftPolicy: ChatDraftPolicy = ChatDraftPolicy.Unrestricted,
  onRetry: ((String) -> Unit)? = null,
  onSend: (String) -> Unit,
) {
  val listState = rememberLazyListState()
  LaunchedEffect(messages.lastOrNull()?.id) {
    if (messages.isNotEmpty()) listState.animateScrollToItem(messages.lastIndex)
  }
  Column(modifier.background(theme.background).imePadding()) {
    LazyColumn(
      state = listState,
      modifier = Modifier.weight(1f).fillMaxWidth(),
      contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
      verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
      if (messages.isEmpty()) {
        item { Text(strings.emptyMessage, Modifier.fillMaxWidth().padding(vertical = 48.dp), textAlign = TextAlign.Center) }
      } else {
        items(messages, key = { it.id }) { message ->
          ChatMessageRow(message, currentUserId, theme, strings, showsSenderName, onRetry?.let { { it(message.id) } })
        }
      }
    }
    ChatComposer(
      draft = draft,
      onDraftChange = onDraftChange,
      placeholder = strings.messagePlaceholder,
      sendButtonLabel = strings.sendButtonLabel,
      draftPolicy = draftPolicy,
      theme = theme,
      onSend = { text -> onSend(text); onDraftChange("") },
    )
  }
}

@Composable
fun ChatMessageRow(
  message: ChatMessage,
  currentUserId: String,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  strings: ChatRoomStrings = ChatRoomStrings.localized(),
  showsSenderName: Boolean = false,
  onRetry: (() -> Unit)? = null,
) {
  when (val content = message.content) {
    is ChatMessageContent.System -> ChatSystemEventCard(theme) {
      Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(content.value, style = MaterialTheme.typography.bodySmall, textAlign = TextAlign.Center)
        Text(formatTime(message.createdAtEpochMillis), style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
      }
    }
    is ChatMessageContent.Text -> {
      val own = message.isSentBy(currentUserId)
      Row(Modifier.fillMaxWidth(), horizontalArrangement = if (own) Arrangement.End else Arrangement.Start) {
        Column(horizontalAlignment = if (own) Alignment.End else Alignment.Start) {
          if (showsSenderName && !own) Text(message.sender?.displayName ?: strings.unknownSender, style = MaterialTheme.typography.labelSmall)
          ChatMessageBubble(isOwnMessage = own, theme = theme) {
            Text(
              content.value,
              Modifier.padding(
                start = if (own) 14.dp else 22.dp,
                end = if (own) 22.dp else 14.dp,
                top = 10.dp,
                bottom = 10.dp,
              ),
            )
          }
          Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
            Text(formatTime(message.createdAtEpochMillis), style = MaterialTheme.typography.labelSmall)
            ChatDeliveryIndicator(message.deliveryState, strings.sendingLabel, strings.failedLabel, theme, onRetry)
          }
        }
      }
    }
  }
}

@Composable
fun ChatComposer(
  draft: String,
  onDraftChange: (String) -> Unit,
  placeholder: String,
  sendButtonLabel: String,
  modifier: Modifier = Modifier,
  isInputSurfacePresented: Boolean = false,
  inputSurfaceHeight: Dp = 0.dp,
  inputSurfaceButtonLabel: String = "",
  inputSurfaceButtonHint: String? = null,
  showsInputSurfaceButton: Boolean = false,
  isSending: Boolean = false,
  draftPolicy: ChatDraftPolicy = ChatDraftPolicy(maximumLength = 500, warningThreshold = 450),
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  attachmentPreview: @Composable () -> Unit = {},
  inputSurface: @Composable () -> Unit = {},
  onToggleInputSurface: () -> Unit = {},
  onSend: (String) -> Unit,
) {
  val normalized = draftPolicy.normalizedText(draft)
  Column(modifier.fillMaxWidth().background(MaterialTheme.colorScheme.surface).padding(horizontal = 16.dp, vertical = 10.dp), horizontalAlignment = Alignment.End) {
    attachmentPreview()
    Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
      Row(Modifier.weight(1f).background(theme.composerField, RoundedCornerShape(24.dp)), verticalAlignment = Alignment.CenterVertically) {
        BasicTextField(
          value = draft,
          onValueChange = { onDraftChange(draftPolicy.limited(it)) },
          modifier = Modifier.weight(1f).testTag("AltiveChatUI.Composer").padding(horizontal = 16.dp, vertical = 12.dp),
          textStyle = MaterialTheme.typography.bodyLarge.copy(color = MaterialTheme.colorScheme.onSurface),
          cursorBrush = SolidColor(MaterialTheme.colorScheme.primary),
          decorationBox = { inner -> if (draft.isEmpty()) Text(placeholder, color = MaterialTheme.colorScheme.onSurfaceVariant); inner() },
        )
        if (showsInputSurfaceButton) TextButton(
          onClick = onToggleInputSurface,
          modifier = Modifier.semantics {
            contentDescription = listOfNotNull(inputSurfaceButtonLabel, inputSurfaceButtonHint).joinToString(". ")
          },
        ) { Text(if (isInputSurfacePresented) "⌨" else "☺") }
      }
      IconButton(
        onClick = { normalized?.let(onSend) },
        enabled = normalized != null && !isSending,
        modifier = Modifier.size(42.dp).testTag("AltiveChatUI.SendButton").clip(CircleShape).background(theme.sendButtonBackground).semantics { contentDescription = sendButtonLabel },
      ) {
        if (isSending) CircularProgressIndicator(Modifier.size(20.dp), color = theme.sendButtonForeground)
        else Text("↑", color = theme.sendButtonForeground, style = MaterialTheme.typography.titleLarge)
      }
    }
    if (draftPolicy.shouldShowLength(draft) && draftPolicy.maximumLength != null) {
      Text("${draftPolicy.length(draft)}/${draftPolicy.maximumLength}", style = MaterialTheme.typography.labelSmall)
    }
    if (isInputSurfacePresented) Box(Modifier.fillMaxWidth().height(inputSurfaceHeight)) { inputSurface() }
  }
}

@Composable
fun ChatComposerAttachmentPreview(
  isSending: Boolean,
  sendButtonLabel: String,
  removeButtonLabel: String,
  onSend: () -> Unit,
  onRemove: () -> Unit,
  modifier: Modifier = Modifier,
  content: @Composable BoxScope.() -> Unit,
) {
  Box(modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
    Box(Modifier.size(120.dp)) {
      TextButton(
        onClick = onSend,
        enabled = !isSending,
        modifier = Modifier.fillMaxSize().semantics { contentDescription = sendButtonLabel },
      ) { Box(Modifier.fillMaxSize(), content = content) }
      TextButton(
        onClick = onRemove,
        modifier = Modifier.align(Alignment.TopEnd).semantics { contentDescription = removeButtonLabel },
      ) { Text("×") }
    }
  }
}

@Composable
fun ChatDeliveryIndicator(
  state: ChatMessageDeliveryState?,
  sendingLabel: String,
  retryLabel: String,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  onRetry: (() -> Unit)? = null,
) {
  when (state) {
    ChatMessageDeliveryState.Sending -> CircularProgressIndicator(Modifier.size(12.dp).semantics { contentDescription = sendingLabel }, strokeWidth = 1.5.dp)
    ChatMessageDeliveryState.Failed -> IconButton(onClick = { onRetry?.invoke() }, enabled = onRetry != null, modifier = Modifier.size(24.dp).semantics { contentDescription = retryLabel }) {
      Text("!", color = theme.deliveryFailure, fontWeight = androidx.compose.ui.text.font.FontWeight.Bold)
    }
    else -> Unit
  }
}

private fun formatTime(epochMillis: Long): String = DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(epochMillis))
