import Testing

@testable import AltiveChatCore

@Suite("チャット入力方針")
struct ChatDraftPolicyTests {
  @Test("UTF-16上限で絵文字を途中分割せず丸める")
  func limitsUTF16WithoutSplittingCharacter() {
    let policy = ChatDraftPolicy(maximumLength: 1_000, lengthUnit: .utf16)
    let acceptedEmoji = String(repeating: "😀", count: 500)
    let tooLongEmoji = acceptedEmoji + "😀"
    let boundarySurrogate = String(repeating: "a", count: 999) + "😀"

    #expect(policy.limited(acceptedEmoji) == acceptedEmoji)
    #expect(policy.limited(tooLongEmoji) == acceptedEmoji)
    #expect(policy.limited(boundarySurrogate).utf16.count == 999)
  }

  @Test("Character上限と警告開始位置を同じ単位で数える")
  func countsCharacters() {
    let policy = ChatDraftPolicy(
      maximumLength: 3,
      warningThreshold: 2,
      lengthUnit: .characters
    )

    #expect(policy.length(of: "a😀") == 2)
    #expect(policy.shouldShowLength(for: "a😀"))
    #expect(policy.limited("a😀bcd") == "a😀b")
  }

  @Test("空白だけの入力を拒否して前後を除く")
  func normalizesText() {
    #expect(ChatDraftPolicy.unrestricted.normalizedText(from: " \n") == nil)
    #expect(ChatDraftPolicy.unrestricted.normalizedText(from: " hello \n") == "hello")
  }
}
