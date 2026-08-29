package jp.co.altive.chat

import kotlin.test.Test
import kotlin.test.assertNull

class ChatReplyConfigurationTest {
  @Test fun `App固有変換ではpackage標準条件を迂回できない`() {
    val sending = ChatMessage(
      id = "sending",
      createdAtEpochMillis = 1L,
      sender = ChatUser("user", "送信者"),
      content = ChatMessageContent.Text("送信中"),
      deliveryState = ChatMessageDeliveryState.Sending,
    )
    val configuration = ChatReplyConfiguration(
      makeReference = { message, _ ->
        ChatReplyReference(
          messageId = message.id,
          senderId = "user",
          senderDisplayName = "送信者",
          content = ChatReplyPreviewContent.Label("カスタム"),
        )
      },
    )

    assertNull(configuration.referenceFor(sending))
  }

  @Test fun `App固有条件で送信済みメッセージを返信対象外にできる`() {
    val message = ChatMessage(
      id = "sent",
      createdAtEpochMillis = 1L,
      sender = ChatUser("user", "送信者"),
      content = ChatMessageContent.Text("本文"),
    )
    val configuration = ChatReplyConfiguration(canReply = { false })

    assertNull(configuration.referenceFor(message))
  }
}
