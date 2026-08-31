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
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import java.text.DateFormat
import java.util.Date

enum class ChatMessageAlignment { Incoming, Outgoing }

/** 投稿者側へ尻尾を伸ばす共通メッセージ吹き出し。 */
@Composable
fun ChatMessageBubble(
  isOwnMessage: Boolean,
  modifier: Modifier = Modifier,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  content: @Composable () -> Unit,
) {
  Surface(
    modifier = modifier,
    shape = ChatMessageBubbleShape(isOwnMessage),
    color = if (isOwnMessage) theme.outgoingBubble else theme.incomingBubble,
    contentColor = if (isOwnMessage) theme.outgoingText else theme.incomingText,
    border = if (isOwnMessage) null else BorderStroke(1.dp, theme.incomingBubbleBorder),
    content = content,
  )
}

/** 投稿者側へ尻尾を伸ばす吹き出し形状。 */
class ChatMessageBubbleShape(
  private val isOwnMessage: Boolean,
) : Shape {
  override fun createOutline(
    size: Size,
    layoutDirection: LayoutDirection,
    density: Density,
  ): Outline {
    val tailWidth = with(density) { 8.dp.toPx() }
    val radius = minOf(with(density) { 18.dp.toPx() }, size.height / 2f)
    val bodyMinX = if (isOwnMessage) 0f else tailWidth
    val bodyMaxX = if (isOwnMessage) size.width - tailWidth else size.width
    val tailTipX = if (isOwnMessage) size.width else 0f
    val tailBaseX = if (isOwnMessage) bodyMaxX else bodyMinX
    val path = Path().apply {
      moveTo(bodyMinX + radius, 0f)
      lineTo(bodyMaxX - radius, 0f)
      quadraticTo(bodyMaxX, 0f, bodyMaxX, radius)
      if (isOwnMessage) {
        lineTo(bodyMaxX, size.height - 18.dp.toPx(density))
        cubicTo(bodyMaxX, size.height - 9.dp.toPx(density), tailTipX - 4.dp.toPx(density), size.height - 4.dp.toPx(density), tailTipX, size.height)
        cubicTo(tailTipX - 4.dp.toPx(density), size.height, tailBaseX - 8.dp.toPx(density), size.height, tailBaseX - 14.dp.toPx(density), size.height)
        lineTo(bodyMinX + radius, size.height)
        quadraticTo(bodyMinX, size.height, bodyMinX, size.height - radius)
      } else {
        lineTo(bodyMaxX, size.height - radius)
        quadraticTo(bodyMaxX, size.height, bodyMaxX - radius, size.height)
        lineTo(tailBaseX + 14.dp.toPx(density), size.height)
        cubicTo(tailBaseX + 8.dp.toPx(density), size.height, tailTipX + 4.dp.toPx(density), size.height, tailTipX, size.height)
        cubicTo(tailTipX + 4.dp.toPx(density), size.height - 4.dp.toPx(density), bodyMinX, size.height - 9.dp.toPx(density), bodyMinX, size.height - 18.dp.toPx(density))
      }
      lineTo(bodyMinX, radius)
      quadraticTo(bodyMinX, 0f, bodyMinX + radius, 0f)
      close()
    }
    return Outline.Generic(path)
  }
}

private fun Dp.toPx(density: Density): Float = with(density) { toPx() }

internal fun visibleReactionCounts(
  counts: List<ChatReactionCount>,
  loadingReactionId: String?,
): List<ChatReactionCount> =
  counts.filter { it.count > 0 || it.reaction.id == loadingReactionId }

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
  val visible = visibleReactionCounts(counts, loadingReactionId)
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
  Box(
    modifier = Modifier.fillMaxWidth().testTag(CHAT_SYSTEM_EVENT_LANE_TAG),
    contentAlignment = Alignment.Center,
  ) {
    Surface(
      modifier = modifier.width(IntrinsicSize.Max).testTag(CHAT_SYSTEM_EVENT_CARD_TAG),
      color = theme.systemBubble,
      shape = RoundedCornerShape(18.dp),
      border = BorderStroke(1.dp, theme.systemBubbleBorder),
    ) {
      ProvideTextStyle(LocalTextStyle.current.copy(textAlign = TextAlign.Center)) {
        Column(Modifier.padding(horizontal = 16.dp, vertical = 4.dp), content = content)
      }
    }
  }
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
        modifier = Modifier
          .heightIn(min = 48.dp)
          .testTag(CHAT_SYSTEM_EVENT_EXPAND_BUTTON_TAG)
          .semantics { contentDescription = expandDescription },
      ) { Text("×${items.size} ${if (expanded) "⌃" else "⌄"}") }
    }
    if (expanded) {
      ProvideTextStyle(LocalTextStyle.current.copy(textAlign = TextAlign.Start)) {
        HorizontalDivider(Modifier.padding(vertical = 8.dp))
        items.forEach { item ->
          Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(item.occurredAtEpochMillis)), style = MaterialTheme.typography.labelSmall)
            Text(item.message, style = MaterialTheme.typography.bodySmall)
          }
        }
      }
    }
    ProvideTextStyle(LocalTextStyle.current.copy(textAlign = TextAlign.Start)) { actions() }
  }
}

internal const val CHAT_SYSTEM_EVENT_LANE_TAG = "AltiveChatUI.SystemEventLane"
internal const val CHAT_SYSTEM_EVENT_CARD_TAG = "AltiveChatUI.SystemEventCard"
internal const val CHAT_SYSTEM_EVENT_EXPAND_BUTTON_TAG = "AltiveChatUI.SystemEventExpandButton"

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
