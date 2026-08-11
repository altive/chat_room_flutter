import Testing

@testable import AltiveChatUI

struct ChatComposerSendPolicyTests {
  @Test func acceptsTextImageOrBoth() {
    #expect(canSend(draft: "hello", imageCount: 0))
    #expect(canSend(draft: "", imageCount: 1))
    #expect(canSend(draft: "hello", imageCount: 2))
  }

  @Test func rejectsEmptyPreparingAndSendingStates() {
    #expect(!canSend(draft: " \n", imageCount: 0))
    #expect(!canSend(draft: "hello", imageCount: 1, isPreparing: true))
    #expect(!canSend(draft: "hello", imageCount: 1, isSending: true))
    #expect(!canSend(draft: "hello", imageCount: 5, maximumImageCount: 4))
  }

  private func canSend(
    draft: String,
    imageCount: Int,
    maximumImageCount: Int? = nil,
    isPreparing: Bool = false,
    isSending: Bool = false
  ) -> Bool {
    ChatComposerSendPolicy.canSend(
      draft: draft,
      imageCount: imageCount,
      maximumImageCount: maximumImageCount,
      isPreparingImages: isPreparing,
      isSending: isSending,
      draftPolicy: .unrestricted
    )
  }
}
