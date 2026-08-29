package jp.co.altive.chat

/** 返信元を再取得せずに引用表示するための軽量な内容。 */
sealed interface ChatReplyPreviewContent {
  data class Text(val value: String) : ChatReplyPreviewContent
  data class Image(
    val thumbnail: ChatImage?,
    val caption: String?,
    val totalCount: Int,
  ) : ChatReplyPreviewContent
  data class Sticker(val reference: ChatStickerReference) : ChatReplyPreviewContent
  data class Label(val value: String) : ChatReplyPreviewContent
  data object Unavailable : ChatReplyPreviewContent
}

/** 返信元の非再帰snapshot。 */
data class ChatReplyReference(
  val messageId: String,
  val senderId: String,
  val senderDisplayName: String,
  val content: ChatReplyPreviewContent,
  val imageIndex: Int? = null,
) {
  companion object {
    /** 送信済みの標準メッセージから返信参照を作る。 */
    fun from(message: ChatMessage, imageIndex: Int? = null): ChatReplyReference? {
      val sender = message.sender ?: return null
      if (message.deliveryState != ChatMessageDeliveryState.Sent) return null
      val (preview, normalizedIndex) = when (val content = message.content) {
        is ChatMessageContent.Text -> ChatReplyPreviewContent.Text(content.value) to null
        is ChatMessageContent.Images -> imagePreview(content.values, null, imageIndex) ?: return null
        is ChatMessageContent.ImagesWithCaption ->
          imagePreview(content.values, content.caption, imageIndex) ?: return null
        is ChatMessageContent.Sticker -> ChatReplyPreviewContent.Sticker(content.reference) to null
        is ChatMessageContent.System -> return null
      }
      return ChatReplyReference(
        messageId = message.id,
        senderId = sender.id,
        senderDisplayName = sender.displayName,
        content = preview,
        imageIndex = normalizedIndex,
      )
    }

    private fun imagePreview(
      images: List<ChatImage>,
      caption: String?,
      requestedIndex: Int?,
    ): Pair<ChatReplyPreviewContent.Image, Int?>? {
      val first = images.firstOrNull() ?: return null
      val normalizedIndex = requestedIndex?.takeIf(images.indices::contains)
      val thumbnail = normalizedIndex?.let(images::get) ?: first
      return ChatReplyPreviewContent.Image(thumbnail, caption, images.size) to normalizedIndex
    }
  }
}
