import Testing

@testable import AltiveChatUI

@Suite("チャットリアクション表示")
struct ChatReactionViewsTests {
  @Test("件数が未反映でも更新中のリアクションを表示する")
  func showsLoadingReactionBeforeCountArrives() {
    let counts = [
      ChatReactionCount(reaction: .heart, count: 1),
      ChatReactionCount(reaction: .like, count: 0),
      ChatReactionCount(reaction: .cheer, count: 0),
    ]

    #expect(
      visibleReactionCounts(counts, loadingReactionID: ChatReaction.like.id).map(\.id)
        == [ChatReaction.heart.id, ChatReaction.like.id]
    )
  }
}
