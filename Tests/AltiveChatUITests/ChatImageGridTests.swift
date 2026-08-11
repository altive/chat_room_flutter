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
}
