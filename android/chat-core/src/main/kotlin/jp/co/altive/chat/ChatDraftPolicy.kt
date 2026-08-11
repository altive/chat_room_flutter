package jp.co.altive.chat

import java.text.BreakIterator

enum class ChatDraftLengthUnit { Characters, Utf16 }

/** Swift 版と同じ入力の上限、警告、送信時正規化契約。 */
class ChatDraftPolicy(
  maximumLength: Int? = null,
  warningThreshold: Int? = null,
  val lengthUnit: ChatDraftLengthUnit = ChatDraftLengthUnit.Characters,
) {
  val maximumLength: Int? = maximumLength?.coerceAtLeast(0)
  val warningThreshold: Int? = warningThreshold?.coerceAtLeast(0)?.let {
    this.maximumLength?.let(it::coerceAtMost) ?: it
  }

  fun length(value: String): Int = when (lengthUnit) {
    ChatDraftLengthUnit.Characters -> characterRanges(value).size
    ChatDraftLengthUnit.Utf16 -> value.length
  }

  fun limited(value: String): String {
    val maximum = maximumLength ?: return value
    if (length(value) <= maximum) return value
    val result = StringBuilder()
    var consumed = 0
    for (range in characterRanges(value)) {
      val character = value.substring(range)
      val width = when (lengthUnit) {
        ChatDraftLengthUnit.Characters -> 1
        ChatDraftLengthUnit.Utf16 -> character.length
      }
      if (consumed + width > maximum) break
      result.append(character)
      consumed += width
    }
    return result.toString()
  }

  fun normalizedText(value: String): String? {
    val normalized = value.trim()
    if (normalized.isEmpty()) return null
    if (maximumLength?.let { length(normalized) > it } == true) return null
    return normalized
  }

  fun shouldShowLength(value: String): Boolean =
    warningThreshold?.let { length(value) >= it } ?: false

  companion object { val Unrestricted = ChatDraftPolicy() }
}

private fun characterRanges(value: String): List<IntRange> {
  val iterator = BreakIterator.getCharacterInstance()
  iterator.setText(value)
  val ranges = mutableListOf<IntRange>()
  var start = iterator.first()
  var end = iterator.next()
  while (end != BreakIterator.DONE) {
    ranges += start until end
    start = end
    end = iterator.next()
  }
  return ranges
}
