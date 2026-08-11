package jp.co.altive.chat

/** チャット画像の読み込み元。UI側の画像ローダーへそのまま渡す。 */
sealed interface ChatImageResource {
  /** 送信中などに表示する端末内のcontent/file URI。 */
  data class LocalUri(val value: String) : ChatImageResource

  /** アップロード後に表示するリモートURL。 */
  data class RemoteUrl(val value: String) : ChatImageResource
}

/** 画像メッセージへ表示する1枚分の画像。 */
data class ChatImage(
  val id: String,
  val resource: ChatImageResource,
  val pixelWidth: Int? = null,
  val pixelHeight: Int? = null,
  val accessibilityLabel: String? = null,
)

/** 送信前の入力欄で保持する画像。 */
data class ChatImageDraft(
  val id: String,
  val localUri: String,
  val pixelWidth: Int? = null,
  val pixelHeight: Int? = null,
  val accessibilityLabel: String? = null,
) {
  val previewImage: ChatImage
    get() = ChatImage(
      id = id,
      resource = ChatImageResource.LocalUri(localUri),
      pixelWidth = pixelWidth,
      pixelHeight = pixelHeight,
      accessibilityLabel = accessibilityLabel,
    )
}

/** テキストと画像をまとめた1回分の送信要求。 */
data class ChatComposerSubmission(
  val text: String?,
  val images: List<ChatImageDraft>,
) {
  companion object {
    /** 入力方針を適用し、テキストまたは画像がある場合だけ送信要求を返す。 */
    fun create(
      draft: String,
      images: List<ChatImageDraft>,
      policy: ChatDraftPolicy,
    ): ChatComposerSubmission? {
      val text = policy.normalizedText(draft)
      if (text == null && images.isEmpty()) return null
      return ChatComposerSubmission(text, images.toList())
    }
  }
}
