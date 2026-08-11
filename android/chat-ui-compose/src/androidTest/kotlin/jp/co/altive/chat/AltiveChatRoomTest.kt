package jp.co.altive.chat

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.v2.createComposeRule
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
}
