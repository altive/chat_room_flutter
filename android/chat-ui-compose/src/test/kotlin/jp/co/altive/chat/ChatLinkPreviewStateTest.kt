package jp.co.altive.chat

import kotlin.test.Test
import kotlin.test.assertEquals

class ChatLinkPreviewStateTest {
  @Test fun `同じURLの表記差があっても送信previewを保持する`() {
    val preview = ChatLinkPreview(
      sourceUrl = "HTTPS://EXAMPLE.COM:443/article#section",
      title = "記事",
    )
    val state = ChatDraftLinkPreviewState.Loaded(preview)

    assertEquals(
      preview,
      state.previewForSubmission("本文 https://example.com/article"),
    )
  }
}
