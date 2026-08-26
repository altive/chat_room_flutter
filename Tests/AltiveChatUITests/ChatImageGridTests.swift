import Foundation
import Testing

@testable import AltiveChatUI

struct ChatImageGridTests {
  @Test(arguments: [(-1, 0), (0, 0), (1, 1), (4, 4), (8, 4)])
  func visibleCount(input: Int, expected: Int) {
    #expect(ChatImageGridMetrics.visibleCount(for: input) == expected)
  }

  @Test(arguments: [(-1, 0), (0, 0), (4, 0), (5, 1), (8, 4)])
  func overflowCount(input: Int, expected: Int) {
    #expect(ChatImageGridMetrics.overflowCount(for: input) == expected)
  }

  @Test("ローカル画像表示後のresource切替では旧画像を保持する")
  @MainActor
  func retainsLoadedImageWhileReplacingResource() {
    let loaded = ChatImageTile.Phase.success(Data([0x01]))

    #expect(loaded.startingReplacement == loaded)
    #expect(loaded.failingReplacement == loaded)
  }

  @Test("初回読み込み失敗時は再試行表示へ移る")
  @MainActor
  func showsFailureForInitialLoadFailure() {
    #expect(ChatImageTile.Phase.loading.failingReplacement == .failure)
  }
}
