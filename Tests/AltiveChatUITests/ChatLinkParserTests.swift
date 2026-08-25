import Foundation
import Testing

@testable import AltiveChatUI

@Suite("チャット本文のリンク検出")
struct ChatLinkParserTests {
  @Test(
    "共通fixture相当のリンクを検出する",
    arguments: [
      (
        "詳細はhttps://example.com/path?q=chatをご覧ください。",
        [("https://example.com/path?q=chat", "https://example.com/path?q=chat", "web")]
      ),
      (
        "www.example.com または example.jp/support",
        [
          ("www.example.com", "https://www.example.com", "web"),
          ("example.jp/support", "https://example.jp/support", "web"),
        ]
      ),
      (
        "support@example.com または mailto:help@example.jp",
        [
          ("support@example.com", "mailto:support@example.com", "email"),
          ("mailto:help@example.jp", "mailto:help@example.jp", "email"),
        ]
      ),
      (
        "090-1234-5678 / +81 90 1234 5678",
        [
          ("090-1234-5678", "tel:09012345678", "phone"),
          ("+81 90 1234 5678", "tel:+819012345678", "phone"),
        ]
      ),
      (
        "tel:03-1234-5678 sms:+819012345678",
        [
          ("tel:03-1234-5678", "tel:0312345678", "phone"),
          ("sms:+819012345678", "sms:+819012345678", "sms"),
        ]
      ),
      ("2026-08-25、12345678、javascript:alert(1)、javascript:example.com", []),
    ]
  )
  func detectsFixtureCases(
    text: String,
    expected: [(text: String, destination: String, kind: String)]
  ) {
    let actual = ChatLinkParser.links(in: text)
      .map { ($0.text, $0.destination.absoluteString, $0.kind.rawValue) }

    #expect(actual.count == expected.count)
    for (actualLink, expectedLink) in zip(actual, expected) {
      #expect(actualLink.0 == expectedLink.text)
      #expect(actualLink.1 == expectedLink.destination)
      #expect(actualLink.2 == expectedLink.kind)
    }
  }

  @Test("URLをメールや電話として重複検出しない")
  func honorsDetectionPriority() {
    let links = ChatLinkParser.links(
      in: "https://example.com/contact?email=user@example.com&phone=09012345678"
    )

    #expect(links.count == 1)
    #expect(links.first?.kind == .web)
  }

  @Test("通常電話番号だけ操作選択を必要とし明示schemeは直接起動する")
  func distinguishesImplicitPhoneNumbers() {
    let links = ChatLinkParser.links(in: "090-1234-5678 tel:03-1234-5678 sms:+819012345678")

    #expect(links.map(\.requiresPhoneActionChoice) == [true, false, false])
  }

  @Test("改行と日本語の閉じ括弧をリンク範囲から除外する")
  func preservesLineBreaksAndTrimsClosingPunctuation() {
    let links = ChatLinkParser.links(in: "参照（https://example.com/a）\nhelp@example.jp。")

    #expect(links.map(\.text) == ["https://example.com/a", "help@example.jp"])
  }

  @Test("電話用の内部URLを元の番号へ戻せる")
  func decodesPhoneActionURL() {
    let attributedString = ChatLinkParser.attributedString(from: "連絡先 +81 90 1234 5678")
    let links = attributedString.runs.compactMap(\.link)

    #expect(links.compactMap(ChatLinkParser.phoneNumber(from:)) == ["+819012345678"])
    #expect(ChatLinkParser.phoneURL(for: "+819012345678").absoluteString == "tel:+819012345678")
    #expect(ChatLinkParser.messageURL(for: "+819012345678").absoluteString == "sms:+819012345678")
  }

  @Test("外部リンクは直接起動し内部電話リンクだけ操作選択へ振り分ける")
  func routesLinkTapActions() throws {
    let webURL = try #require(URL(string: "https://example.com"))
    let phoneLink = ChatLinkParser.attributedString(from: "090-1234-5678")
      .runs
      .compactMap(\.link)
      .first
    let phoneURL = try #require(phoneLink)

    #expect(ChatLinkParser.action(for: webURL) == .open(webURL))
    #expect(ChatLinkParser.action(for: phoneURL) == .choosePhoneAction("09012345678"))

    let explicitTelephoneURL = try #require(
      ChatLinkParser.attributedString(from: "tel:+81-90-1234-5678")
        .runs
        .compactMap(\.link)
        .first
    )
    #expect(
      ChatLinkParser.action(for: explicitTelephoneURL)
        == .open(try #require(URL(string: "tel:+819012345678")))
    )
  }

  @Test("リンク表示Viewを通常本文と同じく構築できる")
  @MainActor
  func createsSelectableLinkedText() {
    let linkedText = ChatLinkedText(text: "example.jp 090-1234-5678", strings: .localized)

    _ = linkedText.body
  }
}
