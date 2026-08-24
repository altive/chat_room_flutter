import Testing

@testable import AltiveChatUI

@Suite("チャットタイムライン位置制御")
struct ChatTimelineTests {
  @Test("準備完了後にスコープごとに1回だけ初期位置を決定する")
  func positionsOncePerScope() {
    var state = ChatTimelinePositioningState<String>()

    let positionsBeforeReady = state.beginInitialPositioning(scope: "family-a", isReady: false)
    let positionsWhenReady = state.beginInitialPositioning(scope: "family-a", isReady: true)
    let positionsAgain = state.beginInitialPositioning(scope: "family-a", isReady: true)

    #expect(!positionsBeforeReady)
    #expect(positionsWhenReady)
    #expect(!positionsAgain)

    state.reset()

    let positionsNewScope = state.beginInitialPositioning(scope: "family-b", isReady: true)
    #expect(positionsNewScope)
  }

  @Test("初期位置決定後のトリガー変更だけ末尾追従する")
  func followsLatestAfterInitialPositioning() {
    var state = ChatTimelinePositioningState<String>()

    #expect(
      !state.shouldFollowLatest(
        scope: "family-a",
        previousTrigger: [String](),
        trigger: ["message-a"]
      )
    )
    let positionsInitially = state.beginInitialPositioning(scope: "family-a", isReady: true)
    #expect(positionsInitially)
    #expect(
      state.shouldFollowLatest(
        scope: "family-a",
        previousTrigger: [String](),
        trigger: ["message-a"]
      )
    )
    #expect(
      !state.shouldFollowLatest(
        scope: "family-b",
        previousTrigger: ["message-a"],
        trigger: ["message-b"]
      )
    )
  }
}
