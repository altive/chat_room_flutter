package jp.co.altive.chat

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ChatCoreTest {
  @Test fun retriesOnlyFailedDelivery() {
    val delivery = ChatDeliveryStateMachine(ChatMessageDeliveryState.Failed)
    assertTrue(delivery.beginRetry())
    assertEquals(ChatMessageDeliveryState.Sending, delivery.state)
    assertFalse(delivery.beginRetry())
    delivery.markSent()
    assertEquals(ChatMessageDeliveryState.Sent, delivery.state)
  }

  @Test fun updatesRecentItemsWithoutDuplicates() {
    assertEquals(listOf("b", "a"), ChatRecentItems.updating(listOf("a", "b", "c"), "b", 2))
    assertTrue(ChatRecentItems.updating(listOf("a"), "b", 0).isEmpty())
  }

  @Test fun exposesStandardReactions() {
    assertEquals(listOf("heart", "like", "celebrate", "thanks", "cheer"), ChatReaction.Standard.map { it.id })
    assertEquals(listOf("❤️", "👍", "🎉", "🙏", "👏"), ChatReaction.Standard.map { it.symbol })
  }

  @Test fun rollsBackOnlyUncontestedOptimisticValue() {
    val mutation = ChatOptimisticMutation.applying(setOf("other")) { it + "me" }
    assertEquals(setOf("other"), mutation.rollingBack(mutation.optimisticValue))
    assertEquals(setOf("other", "me", "newer"), mutation.rollingBack(setOf("other", "me", "newer")))
  }

  @Test fun limitsUtf16WithoutSplittingCharacter() {
    val policy = ChatDraftPolicy(maximumLength = 1_000, lengthUnit = ChatDraftLengthUnit.Utf16)
    val accepted = "😀".repeat(500)
    assertEquals(accepted, policy.limited(accepted + "😀"))
    assertEquals(999, policy.limited("a".repeat(999) + "😀").length)
  }

  @Test fun countsGraphemeCharacters() {
    val policy = ChatDraftPolicy(maximumLength = 2, warningThreshold = 1)
    assertEquals(1, policy.length("e\u0301"))
    assertEquals("e\u0301x", policy.limited("e\u0301xy"))
    assertTrue(policy.shouldShowLength("👨‍👩‍👧‍👦"))
  }

  @Test fun normalizesDraftAndRejectsBlank() {
    assertNull(ChatDraftPolicy.Unrestricted.normalizedText(" \n\t"))
    assertEquals("hello", ChatDraftPolicy.Unrestricted.normalizedText(" hello \n"))
  }

  @Test fun clampsNegativeDraftConfiguration() {
    val policy = ChatDraftPolicy(maximumLength = -1, warningThreshold = 10)
    assertEquals(0, policy.maximumLength)
    assertEquals(0, policy.warningThreshold)
  }

  @Test fun identifiesSenderAndAllowsSenderlessSystemMessage() {
    val sender = ChatUser("me", "Me")
    val text = ChatMessage("m1", 1L, sender, ChatMessageContent.Text("Hello"))
    assertTrue(text.isSentBy("me"))
    assertFalse(text.isSentBy("other"))
    val system = ChatMessage("s1", 2L, null, ChatMessageContent.System("Joined"))
    assertNull(system.sender)
  }

  @Test fun createsTextAndImageSubmissionTogether() {
    val image = ChatImageDraft("image-1", "content://chat/image-1")
    val submission = requireNotNull(
      ChatComposerSubmission.create("  hello\n", listOf(image), ChatDraftPolicy.Unrestricted),
    )
    assertEquals("hello", submission.text)
    assertEquals(listOf(image), submission.images)
  }

  @Test fun acceptsImageOnlyAndRejectsEmptySubmission() {
    val image = ChatImageDraft("image-1", "content://chat/image-1")
    val imageOnly = requireNotNull(
      ChatComposerSubmission.create(" \n", listOf(image), ChatDraftPolicy.Unrestricted),
    )
    assertNull(imageOnly.text)
    assertNull(ChatComposerSubmission.create(" \n", emptyList(), ChatDraftPolicy.Unrestricted))
  }

  @Test fun createsLocalPreviewImageFromDraft() {
    val draft = ChatImageDraft(
      id = "image-1",
      localUri = "content://chat/image-1",
      pixelWidth = 1200,
      pixelHeight = 800,
      accessibilityLabel = "海",
    )
    assertEquals(
      ChatImage(
        id = "image-1",
        resource = ChatImageResource.LocalUri("content://chat/image-1"),
        pixelWidth = 1200,
        pixelHeight = 800,
        accessibilityLabel = "海",
      ),
      draft.previewImage,
    )
  }

  @Test fun keepsImagesAndCaptionInOneMessage() {
    val image = ChatImage("image-1", ChatImageResource.RemoteUrl("https://example.com/image.jpg"))
    val content = ChatMessageContent.ImagesWithCaption(listOf(image), "故障した画面です")

    assertEquals(listOf(image), content.values)
    assertEquals("故障した画面です", content.caption)
  }

  @Test fun clampsInputSurfaceGeometry() {
    assertEquals(310f, ChatInputSurfaceGeometry.keyboardContentHeight(344f, 34f))
    assertEquals(261f, ChatInputSurfaceGeometry.inputSurfaceHeight(310f, 49f))
    assertEquals(0f, ChatInputSurfaceGeometry.inputSurfaceHeight(40f, 49f))
  }
}
