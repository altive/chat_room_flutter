package jp.co.altive.chat

import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable

/** 削除確認で使用する文言。 */
data class ChatDeletionConfirmationStrings(
  val title: String,
  val deleteButton: String,
  val cancelButton: String,
  val message: String? = null,
)

/** 選択中の項目に共通の削除確認を表示する。 */
@Composable
fun <Item> ChatDeletionConfirmation(
  item: Item?,
  onItemChange: (Item?) -> Unit,
  strings: ChatDeletionConfirmationStrings,
  onDelete: (Item) -> Unit,
  onCancel: () -> Unit = {},
) {
  val selectedItem = item ?: return
  fun cancel() {
    onItemChange(null)
    onCancel()
  }
  AlertDialog(
    onDismissRequest = ::cancel,
    title = { Text(strings.title) },
    text = strings.message?.let { message -> { Text(message) } },
    confirmButton = {
      TextButton(
        onClick = {
          onItemChange(null)
          onDelete(selectedItem)
        },
      ) { Text(strings.deleteButton) }
    },
    dismissButton = {
      TextButton(onClick = ::cancel) { Text(strings.cancelButton) }
    },
  )
}
