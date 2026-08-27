package jp.co.altive.chat

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.test.assertIsNotDisplayed
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsFocused
import androidx.compose.ui.test.assertIsNotFocused
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import java.util.concurrent.atomic.AtomicInteger
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

class AltiveChatRoomTest {
  @get:Rule val compose = createComposeRule()

  @Test fun sendsNormalizedTextAndClearsDraft() {
    var sent: String? = null
    var draft by mutableStateOf("")
    compose.setContent {
      MaterialTheme {
        AltiveChatRoom(
          messages = emptyList(),
          currentUserId = "me",
          draft = draft,
          onDraftChange = { draft = it },
          onSend = { sent = it },
        )
      }
    }

    compose.onNodeWithTag("AltiveChatUI.Composer").performTextInput("  Hello  ")
    compose.onNodeWithTag("AltiveChatUI.SendButton").performClick()

    compose.runOnIdle {
      assertEquals("Hello", sent)
      assertEquals("", draft)
    }
  }

  @Test fun `送信失敗アイコンから同じメッセージIDで再送する`() {
    var retriedMessageId: String? = null
    compose.setContent {
      MaterialTheme {
        AltiveChatRoom(
          messages = listOf(
            ChatMessage(
              id = "failed-message",
              createdAtEpochMillis = 1L,
              sender = ChatUser("me", "Me"),
              content = ChatMessageContent.Text("再送する本文"),
              deliveryState = ChatMessageDeliveryState.Failed,
            ),
          ),
          currentUserId = "me",
          draft = "",
          onDraftChange = {},
          strings = ChatRoomStrings("", "", "", "", "Failed to send. Retry", ""),
          onRetry = { retriedMessageId = it },
          onSend = {},
        )
      }
    }

    compose.onNodeWithContentDescription("Failed to send. Retry").performClick()

    compose.runOnIdle { assertEquals("failed-message", retriedMessageId) }
  }

  @Test fun sendsTextAndImagesAsOneSubmissionAndClearsBothDrafts() {
    var submission: ChatComposerSubmission? = null
    var draft by mutableStateOf("")
    compose.setContent {
      var imageDrafts by remember {
        mutableStateOf(listOf(ChatImageDraft("image-1", "content://chat/image-1")))
      }
      MaterialTheme {
        AltiveChatRoom(
          messages = emptyList(),
          currentUserId = "me",
          draft = draft,
          onDraftChange = { draft = it },
          imageDrafts = imageDrafts,
          onImageDraftsChange = { imageDrafts = it },
          resolvePhotoLibraryUri = { error("not used") },
          availableImageInputSources = emptySet(),
          onSubmit = { submission = it },
        )
      }
    }

    compose.onNodeWithTag("AltiveChatUI.Composer").performTextInput("  caption  ")
    compose.onNodeWithTag("AltiveChatUI.SendButton").performClick()

    compose.runOnIdle {
      assertEquals("caption", submission?.text)
      assertEquals(listOf("image-1"), submission?.images?.map(ChatImageDraft::id))
      assertEquals("", draft)
    }
    compose.onNodeWithContentDescription("Remove selected image").assertIsNotDisplayed()
  }

  @Test fun `展開操作で入力欄のフォーカスを外して添付ボタンを戻す`() {
    lateinit var focusRequester: FocusRequester
    compose.setContent {
      var draft by remember { mutableStateOf("") }
      focusRequester = remember { FocusRequester() }
      MaterialTheme {
        AltiveChatRoom(
          messages = emptyList(),
          currentUserId = "me",
          draft = draft,
          onDraftChange = { draft = it },
          imageDrafts = emptyList(),
          onImageDraftsChange = {},
          resolvePhotoLibraryUri = { error("not used") },
          strings = ChatRoomStrings("", "Message", "Send", "", "", ""),
          focusRequester = focusRequester,
          onRequestCamera = {},
          onSubmit = {},
        )
      }
    }

    compose.onNodeWithTag("AltiveChatUI.Composer").performClick()

    compose.onNodeWithContentDescription("Camera").assertIsNotDisplayed()
    compose.onNodeWithTag("AltiveChatUI.ExpandSourceButtons").assertIsDisplayed()
    compose.onNodeWithTag("AltiveChatUI.Composer").assertIsFocused().performTextInput("こんにちは")
    compose.onNodeWithTag("AltiveChatUI.Composer").assertTextEquals("こんにちは")

    compose.onNodeWithTag("AltiveChatUI.ExpandSourceButtons").performClick()

    compose.onNodeWithContentDescription("Camera").assertIsDisplayed()
    compose.onNodeWithTag("AltiveChatUI.Composer").assertIsNotFocused()

    compose.runOnIdle { focusRequester.requestFocus() }

    compose.onNodeWithTag("AltiveChatUI.Composer").assertIsFocused().performTextInput("世界")
    compose.onNodeWithTag("AltiveChatUI.Composer").assertTextEquals("こんにちは世界")
  }

  @Test fun displaysImagesAndCaptionAsOneMessage() {
    val image = ChatImage("image-1", ChatImageResource.RemoteUrl("https://example.com/image.jpg"))
    compose.setContent {
      MaterialTheme {
        AltiveChatRoom(
          messages = listOf(
            ChatMessage(
              id = "message-1",
              createdAtEpochMillis = 1L,
              sender = ChatUser("me", "Me"),
              content = ChatMessageContent.ImagesWithCaption(
                values = listOf(image),
                caption = "故障した画面です",
              ),
            ),
          ),
          currentUserId = "me",
          draft = "",
          onDraftChange = {},
          imageContent = { Text("Image") },
          onSend = {},
        )
      }
    }

    compose.onNodeWithText("故障した画面です").assertIsDisplayed()
  }

  @Test fun `ステッカーassetを解決できない場合は共通の再試行表示を出す`() {
    val attempts = AtomicInteger()
    compose.setContent {
      MaterialTheme {
        AltiveChatRoom(
          messages = listOf(
            ChatMessage(
              id = "sticker",
              createdAtEpochMillis = 1L,
              sender = ChatUser("me", "Me"),
              content = ChatMessageContent.Sticker(
                ChatStickerReference("standard", "thanks", "ja", 3),
              ),
            ),
          ),
          currentUserId = "me",
          draft = "",
          onDraftChange = {},
          strings = ChatRoomStrings(
            "",
            "",
            "",
            "",
            "",
            "",
            stickerLoadingFailedLabel = "Failed to load sticker",
          ),
          stickerImageLoader = ChatStickerImageLoader {
            attempts.incrementAndGet()
            error("assetを解決できません")
          },
          onSend = {},
        )
      }
    }

    compose.waitUntil(timeoutMillis = 5_000) {
      compose.onAllNodesWithText("Failed to load sticker").fetchSemanticsNodes().isNotEmpty()
    }
    compose.onNodeWithText("Failed to load sticker").assertIsDisplayed()
      .performClick()
    compose.waitUntil(timeoutMillis = 5_000) { attempts.get() == 2 }
  }

  @Test fun `通常本文と画像captionとシステム本文にリンクを表示する`() {
    val image = ChatImage("image-1", ChatImageResource.RemoteUrl("https://example.com/image.jpg"))
    compose.setContent {
      MaterialTheme {
        AltiveChatRoom(
          messages = listOf(
            ChatMessage(
              id = "text",
              createdAtEpochMillis = 1L,
              sender = ChatUser("other", "Other"),
              content = ChatMessageContent.Text("https://example.com"),
            ),
            ChatMessage(
              id = "image",
              createdAtEpochMillis = 2L,
              sender = ChatUser("other", "Other"),
              content = ChatMessageContent.ImagesWithCaption(listOf(image), "help@example.jp"),
            ),
            ChatMessage(
              id = "system",
              createdAtEpochMillis = 3L,
              sender = null,
              content = ChatMessageContent.System("sms:+819012345678"),
            ),
          ),
          currentUserId = "me",
          draft = "",
          onDraftChange = {},
          imageContent = { Text("Image") },
          onSend = {},
        )
      }
    }

    compose.onNodeWithText("https://example.com").assertIsDisplayed()
    compose.onNodeWithText("help@example.jp").assertIsDisplayed()
    compose.onNodeWithText("sms:+819012345678").assertIsDisplayed()
  }

  @Test fun `Webとメールと明示telと明示SMSを直接開く`() {
    val opened = mutableListOf<String>()
    compose.setContent {
      MaterialTheme {
        androidx.compose.foundation.layout.Column {
          ChatLinkifiedText("https://example.com", ChatRoomStrings("", "", "", "", "", ""), onOpenLink = opened::add)
          ChatLinkifiedText("help@example.jp", ChatRoomStrings("", "", "", "", "", ""), onOpenLink = opened::add)
          ChatLinkifiedText("tel:03-1234-5678", ChatRoomStrings("", "", "", "", "", ""), onOpenLink = opened::add)
          ChatLinkifiedText("sms:+819012345678", ChatRoomStrings("", "", "", "", "", ""), onOpenLink = opened::add)
        }
      }
    }

    compose.onNodeWithText("https://example.com").performClick()
    compose.onNodeWithText("help@example.jp").performClick()
    compose.onNodeWithText("tel:03-1234-5678").performClick()
    compose.onNodeWithText("sms:+819012345678").performClick()

    compose.runOnIdle {
      assertEquals(
        listOf(
          "https://example.com",
          "mailto:help@example.jp",
          "tel:0312345678",
          "sms:+819012345678",
        ),
        opened,
      )
    }
  }

  @Test fun `電話番号から電話とSMSを選択できキャンセルでは開かない`() {
    val opened = mutableListOf<String>()
    val strings = ChatRoomStrings(
      emptyMessage = "",
      messagePlaceholder = "",
      sendButtonLabel = "",
      sendingLabel = "",
      failedLabel = "",
      unknownSender = "",
      phoneActionTitle = "電話番号への連絡",
      phoneActionMessage = "操作を選択してください",
      callButtonLabel = "電話",
      smsButtonLabel = "SMS",
      cancelButtonLabel = "キャンセル",
    )
    compose.setContent {
      MaterialTheme {
        ChatLinkifiedText("090-1234-5678", strings, onOpenLink = opened::add)
      }
    }

    compose.onNodeWithText("090-1234-5678").performClick()
    compose.onNodeWithText("キャンセル").performClick()
    compose.runOnIdle { assertEquals(emptyList<String>(), opened) }

    compose.onNodeWithText("090-1234-5678").performClick()
    compose.onNodeWithText("SMS").performClick()
    compose.runOnIdle { assertEquals(listOf("sms:09012345678"), opened) }

    compose.onNodeWithText("090-1234-5678").performClick()
    compose.onNodeWithText("電話").performClick()
    compose.runOnIdle {
      assertEquals(listOf("sms:09012345678", "tel:09012345678"), opened)
    }
  }

  @Test fun `汎用メッセージカードの内容と読み上げラベルを表示する`() {
    compose.setContent {
      MaterialTheme {
        ChatMessageCard(
          style = ChatMessageCardStyle.Celebration,
          isOwnMessage = false,
          accessibilityLabel = "お祝いカード",
          header = { Text("お誕生日おめでとう") },
          content = { Text("すてきな一年になりますように") },
          footer = { Text("補足") },
        )
      }
    }

    compose.onNodeWithContentDescription("お祝いカード").assertIsDisplayed()
    compose.onNodeWithText("お誕生日おめでとう").assertIsDisplayed()
    compose.onNodeWithText("すてきな一年になりますように").assertIsDisplayed()
    compose.onNodeWithText("補足").assertIsDisplayed()
  }
}
