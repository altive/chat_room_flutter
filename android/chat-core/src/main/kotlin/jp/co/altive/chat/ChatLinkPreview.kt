package jp.co.altive.chat

import java.net.URI

/** 利用アプリの画像ローダーへそのまま渡すリンクプレビュー画像。 */
data class ChatLinkPreviewImage(
  /** AltiveChatが解釈しない画像resource。 */
  val resource: String,
  val pixelWidth: Int,
  val pixelHeight: Int,
) {
  /** 空resourceや壊れた寸法を画像loaderへ渡さないための表示可否。 */
  val isDisplayable: Boolean
    get() = resource.isNotBlank() && pixelWidth > 0 && pixelHeight > 0

  /** 正の縦横寸法を両方保持している場合だけ返す縦横比。 */
  val aspectRatio: Float?
    get() = if (isDisplayable) pixelWidth.toFloat() / pixelHeight else null
}

/** Webリンクプレビューへ表示する、利用アプリが検証済みの値。 */
data class ChatLinkPreview(
  val sourceUrl: String,
  val title: String,
  val description: String? = null,
  val siteName: String? = null,
  val image: ChatLinkPreviewImage? = null,
) {
  /** HTTP(S) URLと空でないtitleを持ち、安全に表示できるか。 */
  val isDisplayable: Boolean
    get() = title.isNotBlank() && title.length <= 200 &&
      (description == null || description.length <= 500) &&
      (siteName == null || siteName.length <= 100) &&
      normalizeChatLinkPreviewUrl(sourceUrl) != null
}

/** テキスト本文で最初に現れるWeb URLを選択し、scheme省略時はHTTPSへ正規化する。 */
object ChatLinkPreviewParser {
  private val webUrlPattern = Regex(
    "(?<!:)https?://[^\\s<>\\\"'、。，．！？；：]+|" +
      "(?<![@:/\\p{L}\\p{N}._-])(?:www\\.)?" +
      "(?:[\\p{L}\\p{N}](?:[\\p{L}\\p{N}-]{0,61}[\\p{L}\\p{N}])?\\.)+" +
      "[\\p{L}]{2,63}(?::\\d{2,5})?(?:/[^\\s<>\\\"'、。，．！？；：]*)?",
    RegexOption.IGNORE_CASE,
  )
  private val trailingPunctuation =
    setOf('.', ',', '!', '?', ';', ':', '、', '。', '，', '．', '！', '？', '；', '：', ')', ']', '}', '＞', '》', '」', '』', '】')

  /** 本文中の先頭Web URLをHTTP(S)へ正規化して返す。不正な候補しかない場合はnull。 */
  fun firstUrl(text: String): String? = webUrlPattern.findAll(text)
    .map { it.value.trimEnd { character -> character in trailingPunctuation } }
    .map { value ->
      val candidate = if (value.startsWith("http://", ignoreCase = true) ||
        value.startsWith("https://", ignoreCase = true)
      ) {
        value
      } else {
        "https://$value"
      }
      normalizeChatLinkPreviewUrl(candidate)
    }
    .filterNotNull()
    .firstOrNull()
}

/** resolverと保存値の比較に使うHTTP(S) URLへ正規化する。 */
fun normalizeChatLinkPreviewUrl(value: String): String? = runCatching {
  val uri = URI(value)
  val scheme = uri.scheme?.lowercase()
  val host = uri.host?.lowercase()
  if ((scheme != "http" && scheme != "https") || host.isNullOrBlank()) return null
  val port = uri.port.takeUnless {
    (scheme == "http" && it == 80) || (scheme == "https" && it == 443)
  } ?: -1
  URI(scheme, uri.userInfo, host, port, uri.path, uri.query, null).toASCIIString()
}.getOrNull()
