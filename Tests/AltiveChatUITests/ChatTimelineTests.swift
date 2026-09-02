import SwiftUI
import Testing

@testable import AltiveChatUI

@Suite("チャットタイムライン位置制御")
struct ChatTimelineTests {
  @Test("最新位置のanchorは横方向を中央に固定する")
  func latestAnchorKeepsHorizontalCenter() {
    #expect(ChatTimelineScrollAnchor.latest.x == UnitPoint.center.x)
    #expect(ChatTimelineScrollAnchor.latest.y == UnitPoint.bottom.y)
  }

  @Test("content幅をviewportと左右余白の内側へ制限する")
  func capsContentWidthWithinViewportInsets() {
    let insets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

    #expect(
      ChatTimelineContentLayout.contentWidth(
        viewportWidth: 320,
        contentInsets: insets,
        maximumContentWidth: 720
      ) == 288
    )
    #expect(
      ChatTimelineContentLayout.contentWidth(
        viewportWidth: 1_024,
        contentInsets: insets,
        maximumContentWidth: 720
      ) == 720
    )
  }

  @Test("point単位の閾値内を最新付近と判定する")
  func detectsLatestProximityByPoints() {
    #expect(
      ChatTimelineProximity.isNearBottom(
        bottomOffset: 680,
        viewportHeight: 600,
        threshold: 80
      )
    )
    #expect(
      !ChatTimelineProximity.isNearBottom(
        bottomOffset: 681,
        viewportHeight: 600,
        threshold: 80
      )
    )
  }

  @Test("末尾anchorとviewport末端が一致した場合だけ配置完了と判定する")
  func detectsCompletedBottomPosition() {
    #expect(
      ChatTimelineProximity.isAtBottom(
        bottomOffset: 600,
        viewportHeight: 600,
        contentBottomInset: 0
      )
    )
    #expect(
      ChatTimelineProximity.isAtBottom(
        bottomOffset: 520,
        viewportHeight: 600,
        contentBottomInset: 80
      )
    )
    #expect(
      !ChatTimelineProximity.isAtBottom(
        bottomOffset: 0,
        viewportHeight: 600,
        contentBottomInset: 0
      )
    )
    #expect(
      !ChatTimelineProximity.isAtBottom(
        bottomOffset: 0,
        viewportHeight: 0,
        contentBottomInset: 0
      )
    )
  }

  @Test("準備完了後も到達確認までは初期位置を要求中として扱う")
  func keepsInitialPositionPendingUntilCompletion() {
    var state = ChatTimelinePositioningState<String>()

    let positionsBeforeReady = state.beginInitialPositioning(scope: "family-a", isReady: false)
    let positionsWhenReady = state.beginInitialPositioning(scope: "family-a", isReady: true)
    let positionsAgain = state.beginInitialPositioning(scope: "family-a", isReady: true)

    #expect(!positionsBeforeReady)
    #expect(positionsWhenReady)
    #expect(!positionsAgain)
    #expect(state.pendingScope == "family-a")
    #expect(state.positionedScope == nil)
    let completesOtherScope = state.completeInitialPositioning(scope: "family-b")
    let completesPendingScope = state.completeInitialPositioning(scope: "family-a")
    #expect(!completesOtherScope)
    #expect(completesPendingScope)
    #expect(state.pendingScope == nil)
    #expect(state.positionedScope == "family-a")

    state.reset()

    let positionsNewScope = state.beginInitialPositioning(scope: "family-b", isReady: true)
    #expect(positionsNewScope)
    #expect(state.pendingScope == "family-b")
  }

  @Test("リセット前の初期位置完了を新しいスコープへ反映しない")
  func ignoresCompletionFromResetScope() {
    var state = ChatTimelinePositioningState<String>()

    let beginsFirstScope = state.beginInitialPositioning(scope: "family-a", isReady: true)
    #expect(beginsFirstScope)
    state.reset()
    let beginsSecondScope = state.beginInitialPositioning(scope: "family-b", isReady: true)
    #expect(beginsSecondScope)

    let completesResetScope = state.completeInitialPositioning(scope: "family-a")
    #expect(!completesResetScope)
    #expect(state.pendingScope == "family-b")
    let completesCurrentScope = state.completeInitialPositioning(scope: "family-b")
    #expect(completesCurrentScope)
    #expect(state.positionedScope == "family-b")
  }

  @Test("準備解除後は同じスコープの初期位置を再要求できる")
  func retriesInitialPositionAfterReadinessReturns() {
    var state = ChatTimelinePositioningState<String>()

    let beginsPositioning = state.beginInitialPositioning(scope: "family-a", isReady: true)
    #expect(beginsPositioning)
    state.cancelInitialPositioning(scope: "family-a")
    let retriesPositioning = state.beginInitialPositioning(scope: "family-a", isReady: true)

    #expect(retriesPositioning)
    #expect(state.pendingScope == "family-a")
    #expect(state.positionedScope == nil)
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
      !state.shouldFollowLatest(
        scope: "family-a",
        previousTrigger: [String](),
        trigger: ["message-a"]
      )
    )
    let completesInitialPositioning = state.completeInitialPositioning(scope: "family-a")
    #expect(completesInitialPositioning)
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

  @Test("初期位置の対象変更を別の位置決めスコープとして扱う")
  func changesScopeWhenInitialTargetChanges() {
    let latest = ChatTimelinePositioningScope(
      timelineID: AnyHashable("room-a"),
      initialPosition: ChatTimelineInitialPosition<String>.latest
    )
    let specified = ChatTimelinePositioningScope(
      timelineID: AnyHashable("room-a"),
      initialPosition: .item("message-a")
    )

    #expect(latest != specified)
  }

  @Test("末尾付近だけ追従する方針では過去閲覧中の受信へ追従しない")
  func keepsPositionForIncomingMessageWhileBrowsingHistory() {
    let state = ChatTimelinePositioningState<String>()

    #expect(
      !state.shouldFollowLatest(
        isNearBottom: false,
        policy: .whenNearBottom,
        isForced: false
      )
    )
    #expect(
      state.shouldFollowLatest(
        isNearBottom: true,
        policy: .whenNearBottom,
        isForced: false
      )
    )
  }

  @Test("自分の送信は過去閲覧中でも末尾へ追従する")
  func followsOwnMessageWhileBrowsingHistory() {
    let state = ChatTimelinePositioningState<String>()

    #expect(
      state.shouldFollowLatest(
        isNearBottom: false,
        policy: .whenNearBottom,
        isForced: true
      )
    )
  }
}
