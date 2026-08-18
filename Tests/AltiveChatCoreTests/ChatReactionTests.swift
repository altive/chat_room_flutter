import Testing

@testable import AltiveChatCore

@Suite("チャットリアクション")
struct ChatReactionTests {
  @Test("標準リアクションはAPI用IDと表示記号を保持する")
  func exposesStandardReactions() {
    #expect(ChatReaction.standard.map(\.id) == ["heart", "like", "celebrate", "thanks", "cheer"])
    #expect(ChatReaction.standard.map(\.symbol) == ["❤️", "👍", "🎉", "🙏", "👏"])
  }

  @Test("自分の楽観的更新が残っている場合だけロールバックする")
  func rollsBackOnlyOwnOptimisticValue() {
    let mutation = ChatOptimisticMutation(previousValue: Set(["other"])) { members in
      members.insert("me")
    }

    #expect(mutation.optimisticValue == Set(["other", "me"]))
    #expect(mutation.rollingBack(currentValue: mutation.optimisticValue) == Set(["other"]))
    #expect(
      mutation.rollingBack(currentValue: Set(["other", "me", "newer"]))
        == Set(["other", "me", "newer"])
    )
  }
}
