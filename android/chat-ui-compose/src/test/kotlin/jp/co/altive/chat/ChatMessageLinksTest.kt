package jp.co.altive.chat

import kotlin.test.Test
import kotlin.test.assertEquals

class ChatMessageLinksTest {
  @Test fun `Web URLの末尾から日本語の句読点を除外する`() {
    assertLinks(
      "詳細はhttps://example.com/path?q=chatをご覧ください。",
      ExpectedLink("https://example.com/path?q=chat", "https://example.com/path?q=chat", ChatMessageLinkKind.Web),
    )
  }

  @Test fun `wwwとbare domainをHTTPSとして検出する`() {
    assertLinks(
      "www.example.com または example.jp/support",
      ExpectedLink("www.example.com", "https://www.example.com", ChatMessageLinkKind.Web),
      ExpectedLink("example.jp/support", "https://example.jp/support", ChatMessageLinkKind.Web),
    )
  }

  @Test fun `メールとmailto schemeを検出する`() {
    assertLinks(
      "support@example.com または mailto:help@example.jp",
      ExpectedLink("support@example.com", "mailto:support@example.com", ChatMessageLinkKind.Email),
      ExpectedLink("mailto:help@example.jp", "mailto:help@example.jp", ChatMessageLinkKind.Email),
    )
  }

  @Test fun `国内電話と国際電話を正規化する`() {
    assertLinks(
      "090-1234-5678 / +81 90 1234 5678",
      ExpectedLink("090-1234-5678", "tel:09012345678", ChatMessageLinkKind.Phone),
      ExpectedLink("+81 90 1234 5678", "tel:+819012345678", ChatMessageLinkKind.Phone),
    )
  }

  @Test fun `明示的な電話とSMSを検出する`() {
    assertLinks(
      "tel:03-1234-5678 sms:+819012345678",
      ExpectedLink(
        "tel:03-1234-5678",
        "tel:0312345678",
        ChatMessageLinkKind.Phone,
        requiresPhoneActionChoice = false,
      ),
      ExpectedLink("sms:+819012345678", "sms:+819012345678", ChatMessageLinkKind.Sms),
    )
  }

  @Test fun `日付と短い数字と未対応schemeを検出しない`() {
    assertLinks("2026-08-25、12345678、javascript:alert(1)、javascript:example.com")
  }

  @Test fun `不完全なURLとメールアドレスを検出しない`() {
    assertLinks("https:// と www. と user@")
  }

  @Test fun `複数種別と改行を出現順で検出する`() {
    assertLinks(
      "https://example.com\nhelp@example.jp\n090 1234 5678",
      ExpectedLink("https://example.com", "https://example.com", ChatMessageLinkKind.Web),
      ExpectedLink("help@example.jp", "mailto:help@example.jp", ChatMessageLinkKind.Email),
      ExpectedLink("090 1234 5678", "tel:09012345678", ChatMessageLinkKind.Phone),
    )
  }

  private fun assertLinks(text: String, vararg expected: ExpectedLink) {
    assertEquals(
      expected.toList(),
      detectChatMessageLinks(text).map {
        ExpectedLink(it.text, it.destination, it.kind, it.requiresPhoneActionChoice)
      },
    )
  }

  private data class ExpectedLink(
    val text: String,
    val destination: String,
    val kind: ChatMessageLinkKind,
    val requiresPhoneActionChoice: Boolean = kind == ChatMessageLinkKind.Phone,
  )
}
