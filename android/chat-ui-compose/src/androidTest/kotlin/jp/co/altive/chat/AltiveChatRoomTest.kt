package jp.co.altive.chat

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.test.assertIsNotDisplayed
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

class AltiveChatRoomTest {
  @get:Rule val compose = createComposeRule()

  @Test fun sendsNormalizedTextAndClearsDraft() {
    var sent: String? = null
    compose.setContent {
      var draft by remember { mutableStateOf("") }
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

    compose.runOnIdle { assertEquals("Hello", sent) }
    compose.onNodeWithTag("AltiveChatUI.Composer").assertTextEquals("")
  }

  @Test fun sendsTextAndImagesAsOneSubmissionAndClearsBothDrafts() {
    var submission: ChatComposerSubmission? = null
    compose.setContent {
      var draft by remember { mutableStateOf("") }
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
    }
    compose.onNodeWithTag("AltiveChatUI.Composer").assertTextEquals("")
    compose.onNodeWithContentDescription("Remove selected image").assertIsNotDisplayed()
  }
}
