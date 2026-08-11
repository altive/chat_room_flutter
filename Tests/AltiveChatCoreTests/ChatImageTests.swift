import Foundation
import Testing

@testable import AltiveChatCore

struct ChatImageTests {
  @Test func submissionNormalizesTextAndKeepsImages() throws {
    let image = ChatImageDraft(id: "image-1", fileURL: URL(fileURLWithPath: "/tmp/image.jpg"))

    let submission = try #require(
      ChatComposerSubmission(
        draft: "  hello\n",
        images: [image],
        policy: .unrestricted
      )
    )

    #expect(submission.text == "hello")
    #expect(submission.images == [image])
  }

  @Test func imageOnlySubmissionIsValid() throws {
    let image = ChatImageDraft(id: "image-1", fileURL: URL(fileURLWithPath: "/tmp/image.jpg"))
    let submission = try #require(
      ChatComposerSubmission(draft: " \n", images: [image], policy: .unrestricted)
    )

    #expect(submission.text == nil)
  }

  @Test func emptySubmissionIsRejected() {
    #expect(ChatComposerSubmission(text: " \n", images: []) == nil)
  }

  @Test func draftCreatesLocalPreviewImage() {
    let url = URL(fileURLWithPath: "/tmp/image.jpg")
    let draft = ChatImageDraft(
      id: "image-1",
      fileURL: url,
      pixelWidth: 1200,
      pixelHeight: 800,
      accessibilityLabel: "海"
    )

    #expect(
      draft.previewImage
        == ChatImage(
          id: "image-1",
          resource: .localFile(url),
          pixelWidth: 1200,
          pixelHeight: 800,
          accessibilityLabel: "海"
        )
    )
  }
}
