package jp.co.altive.chat

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp

/** メッセージカードの意味的な外観。 */
@Immutable
enum class ChatMessageCardStyle {
  /** 誕生日や記念日などのお祝いに使う外観。 */
  Celebration,
}

/** アプリが構築した内容を表示する汎用メッセージカード。 */
@Composable
fun ChatMessageCard(
  style: ChatMessageCardStyle,
  isOwnMessage: Boolean,
  accessibilityLabel: String,
  modifier: Modifier = Modifier,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  header: @Composable ColumnScope.() -> Unit,
  content: @Composable ColumnScope.() -> Unit,
  footer: (@Composable ColumnScope.() -> Unit)? = null,
) {
  val shape = RoundedCornerShape(
    topStart = 20.dp,
    topEnd = 20.dp,
    bottomStart = if (isOwnMessage) 20.dp else 8.dp,
    bottomEnd = if (isOwnMessage) 8.dp else 20.dp,
  )
  val background = when (style) {
    ChatMessageCardStyle.Celebration -> Brush.linearGradient(
      listOf(theme.celebrationCardBackgroundStart, theme.celebrationCardBackgroundEnd),
    )
  }

  Box(
    modifier = modifier
      .clip(shape)
      .background(background)
      .border(1.dp, theme.celebrationCardBorder, shape)
      .semantics(mergeDescendants = true) { contentDescription = accessibilityLabel },
  ) {
    CelebrationCardDecoration(
      accent = theme.celebrationCardAccent,
      modifier = Modifier.matchParentSize(),
    )
    CompositionLocalProvider(LocalContentColor provides theme.celebrationCardForeground) {
      Column(Modifier.padding(16.dp)) {
        header()
        Spacer(Modifier.size(8.dp))
        content()
        if (footer != null) {
          Spacer(Modifier.size(12.dp))
          footer()
        }
      }
    }
  }
}

@Composable
private fun CelebrationCardDecoration(
  accent: androidx.compose.ui.graphics.Color,
  modifier: Modifier = Modifier,
) {
  Canvas(modifier) {
    drawCircle(
      color = accent.copy(alpha = .2f),
      radius = 5.dp.toPx(),
      center = Offset(size.width * .12f, size.height * .18f),
    )
    drawCircle(
      color = accent.copy(alpha = .16f),
      radius = 3.5.dp.toPx(),
      center = Offset(size.width * .88f, size.height * .3f),
    )
    rotate(degrees = 38f, pivot = Offset(size.width * .78f, size.height * .82f)) {
      drawRect(
        color = accent.copy(alpha = .18f),
        topLeft = Offset(size.width * .78f - 7.dp.toPx(), size.height * .82f - 2.dp.toPx()),
        size = androidx.compose.ui.geometry.Size(14.dp.toPx(), 4.dp.toPx()),
      )
    }
  }
}
