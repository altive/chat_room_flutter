package jp.co.altive.chat

/** UI に必要な値だけを持つチャット利用者。 */
data class ChatUser(
  val id: String,
  val displayName: String,
  val avatarUrl: String? = null,
)

sealed interface ChatMessageContent {
  data class Text(val value: String) : ChatMessageContent
  data class Images(val values: List<ChatImage>) : ChatMessageContent
  data class ImagesWithCaption(val values: List<ChatImage>, val caption: String) : ChatMessageContent
  data class Sticker(val reference: ChatStickerReference) : ChatMessageContent
  data class System(val value: String) : ChatMessageContent
}

enum class ChatMessageDeliveryState { Sent, Sending, Failed }

data class ChatMessage(
  val id: String,
  val createdAtEpochMillis: Long,
  val sender: ChatUser?,
  val content: ChatMessageContent,
  val deliveryState: ChatMessageDeliveryState = ChatMessageDeliveryState.Sent,
  /** テキストメッセージへ任意に表示するWebリンクプレビュー。 */
  val linkPreview: ChatLinkPreview? = null,
  /** 返信元の軽量な表示snapshot。 */
  val replyTo: ChatReplyReference? = null,
) {
  fun isSentBy(userId: String): Boolean = sender?.id == userId
}

class ChatDeliveryStateMachine(
  state: ChatMessageDeliveryState = ChatMessageDeliveryState.Sending,
) {
  var state: ChatMessageDeliveryState = state
    private set

  fun beginRetry(): Boolean {
    if (state != ChatMessageDeliveryState.Failed) return false
    state = ChatMessageDeliveryState.Sending
    return true
  }

  fun markSent() { state = ChatMessageDeliveryState.Sent }
  fun markFailed() { state = ChatMessageDeliveryState.Failed }
}

data class ChatSystemEventItem(
  val id: String,
  val occurredAtEpochMillis: Long,
  val message: String,
)
