package jp.co.altive.chat

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import java.time.Instant
import java.time.ZoneId

/** タイムライン区切りの外観。 */
enum class ChatTimelineSeparatorStyle {
  /** 日付などを明確に示す強調表示。 */
  Emphasized,

  /** 未読位置などへ馴染ませる控えめな表示。 */
  Subtle,
}

/** 日付や未読位置をタイムライン内で区切る共通表示。 */
@Composable
fun ChatTimelineSeparator(
  text: String,
  modifier: Modifier = Modifier,
  style: ChatTimelineSeparatorStyle = ChatTimelineSeparatorStyle.Emphasized,
) {
  Row(
    modifier = modifier.fillMaxWidth().semantics { contentDescription = text },
    horizontalArrangement = Arrangement.spacedBy(if (style == ChatTimelineSeparatorStyle.Emphasized) 12.dp else 8.dp),
    verticalAlignment = Alignment.CenterVertically,
  ) {
    HorizontalDivider(Modifier.weight(1f))
    Text(
      text = text,
      modifier = Modifier.padding(vertical = 4.dp),
      color = MaterialTheme.colorScheme.onSurfaceVariant,
      style = MaterialTheme.typography.labelSmall,
      fontWeight = if (style == ChatTimelineSeparatorStyle.Emphasized) FontWeight.SemiBold else FontWeight.Normal,
    )
    HorizontalDivider(Modifier.weight(1f))
  }
}

/** タイムライン区切りの挿入判定。 */
object ChatTimelineSectioning {
  /** 現在項目の前へ日付区切りを挿入するか返す。 */
  fun startsNewDay(
    currentEpochMillis: Long,
    previousEpochMillis: Long?,
    zoneId: ZoneId = ZoneId.systemDefault(),
  ): Boolean {
    val current = Instant.ofEpochMilli(currentEpochMillis).atZone(zoneId).toLocalDate()
    val previous = previousEpochMillis?.let { Instant.ofEpochMilli(it).atZone(zoneId).toLocalDate() }
    return previous == null || previous != current
  }

  /** 現在項目の前へ未読区切りを挿入するか返す。 */
  fun startsUnreadSection(isUnread: Boolean, wasPreviousUnread: Boolean): Boolean =
    isUnread && !wasPreviousUnread
}
