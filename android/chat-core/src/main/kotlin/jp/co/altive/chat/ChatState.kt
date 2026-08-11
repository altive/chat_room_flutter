package jp.co.altive.chat

data class ChatReaction(val id: String, val symbol: String, val accessibilityLabel: String) {
  companion object {
    val Heart = ChatReaction("heart", "❤️", "❤️")
    val Celebrate = ChatReaction("celebrate", "🎉", "🎉")
    val Thanks = ChatReaction("thanks", "🙏", "🙏")
    val Cheer = ChatReaction("cheer", "👏", "👏")
    val Standard = listOf(Heart, Celebrate, Thanks, Cheer)
  }
}

data class ChatReactionCount(val reaction: ChatReaction, val count: Int)

data class ChatOptimisticMutation<T>(val previousValue: T, val optimisticValue: T) {
  fun rollingBack(currentValue: T): T =
    if (currentValue == optimisticValue) previousValue else currentValue

  companion object {
    fun <T> applying(previousValue: T, update: (T) -> T) =
      ChatOptimisticMutation(previousValue, update(previousValue))
  }
}

data class ChatStickerReference(
  val packId: String,
  val stickerId: String,
  val locale: String,
  val assetRevision: Int,
)

object ChatRecentItems {
  fun <T> updating(values: List<T>, adding: T, limit: Int): List<T> =
    if (limit <= 0) emptyList() else (listOf(adding) + values.filterNot { it == adding }).take(limit)
}

object ChatInputSurfaceGeometry {
  fun keyboardContentHeight(overlapHeight: Float, bottomSafeAreaInset: Float): Float =
    (overlapHeight - bottomSafeAreaInset).coerceAtLeast(0f)

  fun inputSurfaceHeight(keyboardContentHeight: Float, bottomChromeHeight: Float): Float =
    (keyboardContentHeight - bottomChromeHeight).coerceAtLeast(0f)
}
