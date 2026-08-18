package jp.co.altive.chat

import kotlin.test.Test
import kotlin.test.assertEquals

class ChatReactionTest {
  @Test fun `件数が未反映でも更新中のリアクションを表示する`() {
    val counts = listOf(
      ChatReactionCount(ChatReaction.Heart, 1),
      ChatReactionCount(ChatReaction.Like, 0),
      ChatReactionCount(ChatReaction.Cheer, 0),
    )

    assertEquals(
      listOf(ChatReaction.Heart.id, ChatReaction.Like.id),
      visibleReactionCounts(counts, ChatReaction.Like.id).map { it.reaction.id },
    )
  }
}
