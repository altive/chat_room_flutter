package jp.co.altive.chat

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ChatDeletionConfirmationTest {
  @get:Rule val compose = createComposeRule()

  @Test
  fun `削除時は選択を解除して削除だけを通知する`() {
    var item by mutableStateOf<Int?>(1)
    var deletedItem: Int? = null
    var cancelCount = 0
    compose.setContent {
      MaterialTheme {
        ChatDeletionConfirmation(
          item = item,
          onItemChange = { item = it },
          strings = strings,
          onDelete = { deletedItem = it },
          onCancel = { cancelCount += 1 },
        )
      }
    }

    compose.onNodeWithText("削除").performClick()

    compose.runOnIdle {
      assertNull(item)
      assertEquals(1, deletedItem)
      assertEquals(0, cancelCount)
    }
  }

  @Test
  fun `キャンセル時は選択を解除して一度だけ通知する`() {
    var item by mutableStateOf<Int?>(1)
    var deleteCount = 0
    var cancelCount = 0
    compose.setContent {
      MaterialTheme {
        ChatDeletionConfirmation(
          item = item,
          onItemChange = { item = it },
          strings = strings,
          onDelete = { deleteCount += 1 },
          onCancel = { cancelCount += 1 },
        )
      }
    }

    compose.onNodeWithText("キャンセル").performClick()

    compose.runOnIdle {
      assertNull(item)
      assertEquals(0, deleteCount)
      assertEquals(1, cancelCount)
    }
  }

  private companion object {
    val strings = ChatDeletionConfirmationStrings(
      title = "削除しますか？",
      deleteButton = "削除",
      cancelButton = "キャンセル",
    )
  }
}
