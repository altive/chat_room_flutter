package jp.co.altive.chat

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withLink

internal class ChatMessageLinkKind private constructor() {
  companion object {
    val Web = ChatMessageLinkKind()
    val Email = ChatMessageLinkKind()
    val Phone = ChatMessageLinkKind()
    val Sms = ChatMessageLinkKind()
  }
}

internal data class ChatMessageLink(
  val text: String,
  val destination: String,
  val kind: ChatMessageLinkKind,
  val range: IntRange,
  val requiresPhoneActionChoice: Boolean = false,
)

private data class LinkCandidate(
  val range: IntRange,
  val priority: Int,
  val kind: ChatMessageLinkKind,
  val requiresPhoneActionChoice: Boolean = false,
  val destination: (String) -> String,
)

private val explicitWebPattern = Regex(
  "(?i)https?://[a-z0-9.-]+(?::\\d{2,5})?(?:/[a-z0-9._~:/?#\\[\\]@!\$&'()*+,;=%-]*)?",
)
private val explicitActionPattern = Regex(
  "(?i)(?:mailto:[a-z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-z0-9.-]+\\.[a-z]{2,}|(?:tel|sms):\\+?\\d[\\d ()-]*\\d)",
)
private val webLinkPattern = Regex(
  "(?i)(?:www\\.)?(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}(?::\\d{2,5})?(?:/[^\\s<>]*)?",
)
private val emailLinkPattern = Regex(
  "(?i)[a-z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+",
)
private val phoneLinkPattern = Regex("(?<![\\p{L}\\p{N}])\\+?\\d[\\d ()-]{7,}\\d(?![\\p{L}\\p{N}])")
private val trailingPunctuation = setOf(
  '.', ',', '!', '?', ':', ';', '。', '、', '！', '？', '：', '；',
  '，', '．', '」', '』', '】', '〕', '〉', '》', '）', ']', '}',
)

internal fun detectChatMessageLinks(text: String): List<ChatMessageLink> {
  val candidates = buildList {
    explicitWebPattern.findAll(text).forEach { match ->
      val range = trimmedLinkRange(text, match.range)
      add(LinkCandidate(range, 0, ChatMessageLinkKind.Web) { it })
    }
    explicitActionPattern.findAll(text).forEach { match ->
      val range = trimmedLinkRange(text, match.range)
      val value = text.substring(range)
      when {
        value.startsWith("mailto:", true) ->
          add(LinkCandidate(range, 0, ChatMessageLinkKind.Email) { "mailto:${it.substringAfter(':')}" })
        value.startsWith("tel:", true) -> {
          val normalized = normalizePhone(value.substringAfter(':'))
          if (normalized != null) {
            add(LinkCandidate(range, 0, ChatMessageLinkKind.Phone) { "tel:$normalized" })
          }
        }
        value.startsWith("sms:", true) -> {
          val normalized = normalizePhone(value.substringAfter(':'))
          if (normalized != null) add(LinkCandidate(range, 0, ChatMessageLinkKind.Sms) { "sms:$normalized" })
        }
      }
    }
    webLinkPattern.findAll(text).forEach { match ->
      val range = trimmedLinkRange(text, match.range)
      val preceding = text.getOrNull(range.first - 1)
      if (preceding != '@' && preceding != ':' && preceding?.isLetterOrDigit() != true) {
        add(LinkCandidate(range, 1, ChatMessageLinkKind.Web) { value -> "https://$value" })
      }
    }
    emailLinkPattern.findAll(text).forEach { match ->
      add(LinkCandidate(match.range, 2, ChatMessageLinkKind.Email) { "mailto:$it" })
    }
    phoneLinkPattern.findAll(text).forEach { match ->
      val normalized = normalizePhone(match.value) ?: return@forEach
      add(
        LinkCandidate(
          match.range,
          3,
          ChatMessageLinkKind.Phone,
          requiresPhoneActionChoice = true,
        ) { "tel:$normalized" },
      )
    }
  }

  val accepted = mutableListOf<LinkCandidate>()
  for (candidate in candidates.sortedWith(compareBy(LinkCandidate::priority, { it.range.first }))) {
    if (accepted.none { rangesOverlap(it.range, candidate.range) }) accepted += candidate
  }
  return accepted.sortedBy { it.range.first }.map { candidate ->
    val value = text.substring(candidate.range)
    ChatMessageLink(
      value,
      candidate.destination(value),
      candidate.kind,
      candidate.range,
      candidate.requiresPhoneActionChoice,
    )
  }
}

private fun normalizePhone(value: String): String? {
  val hasLeadingPlus = value.trimStart().startsWith('+')
  val digits = value.filter(Char::isDigit)
  if (digits.length !in 9..15) return null
  return if (hasLeadingPlus) "+$digits" else digits
}

private fun trimmedLinkRange(text: String, source: IntRange): IntRange {
  var end = source.last
  while (end >= source.first) {
    val character = text[end]
    val shouldTrimClosingParenthesis = character == ')' &&
      text.substring(source.first, end + 1).count { it == ')' } >
      text.substring(source.first, end + 1).count { it == '(' }
    if (character !in trailingPunctuation && !shouldTrimClosingParenthesis) break
    end--
  }
  return source.first..end
}

private fun rangesOverlap(lhs: IntRange, rhs: IntRange): Boolean =
  lhs.first <= rhs.last && rhs.first <= lhs.last

/** チャット本文のリンクを表示し、対応するOS標準アプリを開くテキスト。 */
@Composable
fun ChatLinkifiedText(
  text: String,
  strings: ChatRoomStrings,
  modifier: Modifier = Modifier,
  color: Color = Color.Unspecified,
  style: TextStyle = LocalTextStyle.current,
  textAlign: TextAlign? = null,
  onOpenLink: ((String) -> Unit)? = null,
) {
  val context = LocalContext.current
  val openLink = onOpenLink ?: remember(context) { defaultChatLinkOpener(context) }
  var selectedPhone by remember { mutableStateOf<String?>(null) }
  val links = remember(text) { detectChatMessageLinks(text) }
  val linkColor = if (color == Color.Unspecified) LocalContentColor.current else color
  val annotated = buildAnnotatedString {
    var cursor = 0
    links.forEach { link ->
      append(text.substring(cursor, link.range.first))
      withLink(
        LinkAnnotation.Clickable(
          tag = link.destination,
          styles = TextLinkStyles(
            style = SpanStyle(color = linkColor, textDecoration = TextDecoration.Underline),
          ),
          linkInteractionListener = {
            if (link.requiresPhoneActionChoice) selectedPhone = link.destination
            else openLink(link.destination)
          },
        ),
      ) {
        append(link.text)
      }
      cursor = link.range.last + 1
    }
    append(text.substring(cursor))
  }
  Text(
    text = annotated,
    modifier = modifier,
    color = color,
    style = style,
    textAlign = textAlign,
  )

  selectedPhone?.let { destination ->
    AlertDialog(
      onDismissRequest = { selectedPhone = null },
      title = { Text(strings.phoneActionTitle) },
      text = { Text(strings.phoneActionMessage) },
      confirmButton = {
        TextButton(onClick = {
          selectedPhone = null
          openLink(destination)
        }) { Text(strings.callButtonLabel) }
      },
      dismissButton = {
        androidx.compose.foundation.layout.Row {
          TextButton(onClick = {
            selectedPhone = null
            openLink("sms:${destination.removePrefix("tel:")}")
          }) { Text(strings.smsButtonLabel) }
          TextButton(onClick = { selectedPhone = null }) { Text(strings.cancelButtonLabel) }
        }
      },
    )
  }
}

private fun defaultChatLinkOpener(context: Context): (String) -> Unit = { destination ->
  try {
    context.startActivity(
      Intent(Intent.ACTION_VIEW, Uri.parse(destination)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
    )
  } catch (_: RuntimeException) {
    // 対応アプリがない、不正なURI、OSの制限などで起動できない場合も表示を継続する。
  }
}
