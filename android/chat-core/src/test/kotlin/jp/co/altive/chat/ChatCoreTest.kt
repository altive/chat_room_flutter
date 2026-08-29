package jp.co.altive.chat

import java.nio.file.Files
import java.nio.file.Path
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
    val preview = ChatLinkPreview("https://example.com/article", "記事タイトル")
    val submission = requireNotNull(
      ChatComposerSubmission.create(
        "  hello\n",
        listOf(image),
        ChatDraftPolicy.Unrestricted,
        preview,
      ),
    )
    assertEquals("hello", submission.text)
    assertEquals(listOf(image), submission.images)
    assertEquals(preview, submission.linkPreview)
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

  @Test fun `構造化ステッカー参照をメッセージへ保持する`() {
    val reference = ChatStickerReference("standard", "thanks", "ja", 3)
    val content = ChatMessageContent.Sticker(reference)

    assertEquals(reference, content.reference)
  }

  @Test fun `本文中の先頭Web URLだけをリンクプレビュー対象にする`() {
    assertEquals(
      "https://first.example/path?q=chat",
      ChatLinkPreviewParser.firstUrl(
        "メール support@example.com の後に https://first.example/path?q=chat、次に http://second.example",
      ),
    )
  }

  @Test fun `scheme省略Web URLをHTTPSへ正規化してメールアドレスを除外する`() {
    assertEquals("https://example.jp/news", ChatLinkPreviewParser.firstUrl("example.jp/news"))
    assertEquals("https://www.example.com", ChatLinkPreviewParser.firstUrl("www.example.com"))
    assertNull(ChatLinkPreviewParser.firstUrl("support@example.jp"))
  }

  @Test fun `共通fixtureのselectionCasesを全件検証する`() {
    val fixture = Files.readString(linkPreviewFixturePath())
    val selectionCases = fixture
      .substringAfter("\"selectionCases\": [")
      .substringBefore("\n  ],")
    val cases = Regex("\\{[^{}]*}").findAll(selectionCases).map { objectMatch ->
      val value = objectMatch.value
      val name = requireNotNull(jsonString(value, "name"))
      val text = requireNotNull(jsonString(value, "text"))
      val expected = jsonString(value, "sourceUrl")
      Triple(name, text, expected)
    }.toList()

    assertTrue(cases.isNotEmpty())
    cases.forEach { (name, text, expected) ->
      assertEquals(expected, ChatLinkPreviewParser.firstUrl(text), name)
    }
  }

  @Test fun `不正schemeと不完全URLをリンクプレビュー対象にしない`() {
    assertNull(ChatLinkPreviewParser.firstUrl("ftp://example.com javascript:alert(1) https://"))
    assertNull(ChatLinkPreviewParser.firstUrl("javascript:https://example.com"))
  }

  @Test fun `表示可能なリンクプレビューと壊れた画像寸法を安全に判定する`() {
    val preview = ChatLinkPreview(
      sourceUrl = "https://example.com",
      title = "タイトル",
      image = ChatLinkPreviewImage("storage/path", pixelWidth = 1200, pixelHeight = 630),
    )
    assertTrue(preview.isDisplayable)
    assertEquals(1200f / 630f, preview.image?.aspectRatio)
    assertFalse(preview.copy(title = " ").isDisplayable)
    assertFalse(preview.copy(title = "a".repeat(201)).isDisplayable)
    assertFalse(preview.copy(description = "a".repeat(501)).isDisplayable)
    assertFalse(preview.copy(siteName = "a".repeat(101)).isDisplayable)
    assertFalse(preview.copy(sourceUrl = "javascript:alert(1)").isDisplayable)
    val brokenImage = ChatLinkPreviewImage("storage/path", pixelWidth = -1, pixelHeight = 630)
    assertFalse(brokenImage.isDisplayable)
    assertNull(brokenImage.aspectRatio)
  }

  @Test fun `本文なしsubmissionはリンクプレビューを保持しない`() {
    val preview = ChatLinkPreview("https://example.com", "Example")
    val image = ChatImageDraft(
      id = "image",
      localUri = "content://image",
    )

    assertNull(
      ChatComposerSubmission.create(
        draft = "",
        images = listOf(image),
        policy = ChatDraftPolicy.Unrestricted,
        linkPreview = preview,
      )?.linkPreview,
    )
  }

  @Test fun clampsInputSurfaceGeometry() {
    assertEquals(310f, ChatInputSurfaceGeometry.keyboardContentHeight(344f, 34f))
    assertEquals(261f, ChatInputSurfaceGeometry.inputSurfaceHeight(310f, 49f))
    assertEquals(0f, ChatInputSurfaceGeometry.inputSurfaceHeight(40f, 49f))
  }
}

private fun linkPreviewFixturePath(): Path = generateSequence(Path.of("").toAbsolutePath()) { it.parent }
  .map { it.resolve("contract/fixtures/link-preview-cases.json") }
  .firstOrNull(Files::exists)
  ?: error("contract/fixtures/link-preview-cases.jsonが見つかりません")

private fun jsonString(objectJson: String, key: String): String? {
  if (Regex("\\\"$key\\\"\\s*:\\s*null").containsMatchIn(objectJson)) return null
  return Regex("\\\"$key\\\"\\s*:\\s*\\\"([^\\\"]*)\\\"")
    .find(objectJson)
    ?.groupValues
    ?.get(1)
}
