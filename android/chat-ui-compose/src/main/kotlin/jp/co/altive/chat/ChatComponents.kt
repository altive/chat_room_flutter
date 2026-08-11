package jp.co.altive.chat

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import java.text.DateFormat
import java.util.Date

enum class ChatMessageAlignment { Incoming, Outgoing }

@Composable
fun ChatReactionSummaryBar(
  counts: List<ChatReactionCount>,
  alignment: ChatMessageAlignment,
  modifier: Modifier = Modifier,
  loadingReactionId: String? = null,
  isEnabled: Boolean = true,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  onSelect: ((ChatReaction) -> Unit)? = null,
) {
  val visible = counts.filter { it.count > 0 }
  if (visible.isEmpty()) return
  Row(
    modifier.fillMaxWidth().horizontalScroll(rememberScrollState()),
    horizontalArrangement = if (alignment == ChatMessageAlignment.Outgoing) Arrangement.End else Arrangement.Start,
  ) {
    visible.forEach { item ->
      AssistChip(
        onClick = { onSelect?.invoke(item.reaction) },
        enabled = isEnabled && loadingReactionId != item.reaction.id && onSelect != null,
        label = {
          Row(horizontalArrangement = Arrangement.spacedBy(3.dp)) {
            Text(item.reaction.symbol)
            if (loadingReactionId == item.reaction.id) CircularProgressIndicator(Modifier.size(12.dp), strokeWidth = 1.dp)
            else Text(item.count.toString(), fontWeight = FontWeight.Bold)
          }
        },
        modifier = Modifier.padding(end = 4.dp).semantics { contentDescription = "${item.reaction.accessibilityLabel} ${item.count}" },
        colors = AssistChipDefaults.assistChipColors(containerColor = theme.reactionChipBackground),
        border = BorderStroke(.5.dp, theme.reactionChipBorder),
      )
    }
  }
}

@Composable
fun ChatReactionPicker(
  onSelect: (ChatReaction) -> Unit,
  modifier: Modifier = Modifier,
  reactions: List<ChatReaction> = ChatReaction.Standard,
  isEnabled: Boolean = true,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  trailingActions: (@Composable RowScope.() -> Unit)? = null,
) {
  Row(modifier.padding(8.dp), verticalAlignment = Alignment.CenterVertically) {
    reactions.forEach { reaction ->
      IconButton(
        onClick = { onSelect(reaction) },
        enabled = isEnabled,
        modifier = Modifier.size(44.dp).semantics { contentDescription = reaction.accessibilityLabel },
      ) { Text(reaction.symbol, style = MaterialTheme.typography.titleLarge, modifier = Modifier.background(theme.reactionPickerItemBackground, CircleShape).padding(7.dp)) }
    }
    if (trailingActions != null) {
      if (reactions.isNotEmpty()) VerticalDivider(Modifier.height(24.dp).padding(horizontal = 4.dp))
      trailingActions()
    }
  }
}

@Composable
fun ChatInteractionPopover(
  expanded: Boolean,
  onExpandedChange: (Boolean) -> Unit,
  actions: @Composable () -> Unit,
  modifier: Modifier = Modifier,
  enabled: Boolean = true,
  content: @Composable () -> Unit,
) {
  Box(modifier.combinedClickable(enabled = enabled, onClick = {}, onLongClick = { onExpandedChange(true) })) {
    content()
    DropdownMenu(expanded = expanded, onDismissRequest = { onExpandedChange(false) }) { actions() }
  }
}

data class ChatAvatarStatus(val color: Color, val accessibilityLabel: String)

@Composable
fun ChatAvatar(
  displayName: String,
  modifier: Modifier = Modifier,
  size: Dp = 34.dp,
  accentColor: Color? = null,
  status: ChatAvatarStatus? = null,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  image: @Composable BoxScope.() -> Unit = {},
) {
  Box(modifier.size(size).semantics { contentDescription = displayName }) {
    Box(
      Modifier.fillMaxSize().clip(CircleShape)
        .background(accentColor?.copy(alpha = .2f) ?: theme.avatarFallbackBackground)
        .then(if (accentColor == null) Modifier else Modifier.border(1.dp, accentColor.copy(alpha = .45f), CircleShape)),
      contentAlignment = Alignment.Center,
    ) {
      Text(displayName.trim().firstOrNull()?.toString() ?: "?", color = theme.avatarFallbackForeground, fontWeight = FontWeight.SemiBold)
      image()
    }
    if (status != null) Box(
      Modifier.align(Alignment.BottomEnd).size((size.value * .27f).coerceAtLeast(8f).dp)
        .background(status.color, CircleShape).border(2.dp, MaterialTheme.colorScheme.background, CircleShape)
        .semantics { contentDescription = status.accessibilityLabel },
    )
  }
}

@Composable
fun ChatSystemEventCard(
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  modifier: Modifier = Modifier,
  content: @Composable ColumnScope.() -> Unit,
) {
  Surface(
    modifier = modifier.fillMaxWidth(),
    color = theme.systemBubble,
    shape = RoundedCornerShape(18.dp),
    border = BorderStroke(1.dp, theme.systemBubbleBorder),
  ) { Column(Modifier.padding(horizontal = 16.dp, vertical = 14.dp), content = content) }
}

@Composable
fun ChatSystemEventGroup(
  items: List<ChatSystemEventItem>,
  summary: @Composable RowScope.() -> Unit,
  modifier: Modifier = Modifier,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  actions: @Composable ColumnScope.() -> Unit = {},
) {
  var expanded by remember { mutableStateOf(false) }
  val expandDescription = stringResource(
    if (expanded) R.string.altive_chat_collapse else R.string.altive_chat_expand,
  )
  ChatSystemEventCard(theme, modifier) {
    Row(verticalAlignment = Alignment.CenterVertically) {
      summary()
      if (items.size > 1) TextButton(
        onClick = { expanded = !expanded },
        modifier = Modifier.semantics { contentDescription = expandDescription },
      ) { Text("×${items.size} ${if (expanded) "⌃" else "⌄"}") }
    }
    if (expanded) {
      HorizontalDivider(Modifier.padding(vertical = 8.dp))
      items.forEach { item ->
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
          Text(DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(item.occurredAtEpochMillis)), style = MaterialTheme.typography.labelSmall)
          Text(item.message, style = MaterialTheme.typography.bodySmall)
        }
      }
    }
    actions()
  }
}

@Composable
fun ChatTimelineBoundary(
  title: String,
  onAction: () -> Unit,
  modifier: Modifier = Modifier,
  icon: Painter? = null,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
) {
  TextButton(onClick = onAction, modifier = modifier.heightIn(min = 44.dp), colors = ButtonDefaults.textButtonColors(contentColor = theme.timelineBoundaryForeground)) {
    if (icon != null) Icon(icon, null, Modifier.padding(end = 6.dp))
    Text(title)
    Text(" ›")
  }
}
