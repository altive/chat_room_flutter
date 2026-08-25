import Foundation
import SwiftUI

/// チャット本文に含まれるリンクを表示し、電話番号の起動方法を選択できるテキスト。
@MainActor
struct ChatLinkedText: View {
  let text: String
  let strings: ChatRoomStrings

  @Environment(\.openURL) private var openURL
  @State private var selectedPhoneNumber: String?

  var body: some View {
    Text(ChatLinkParser.attributedString(from: text))
      .textSelection(.enabled)
      .environment(
        \.openURL,
        OpenURLAction { url in
          switch ChatLinkParser.action(for: url) {
          case .open(let destination):
            openURL(destination)
          case .choosePhoneAction(let phoneNumber):
            selectedPhoneNumber = phoneNumber
          }
          return .handled
        }
      )
      .confirmationDialog(
        strings.phoneActionTitle,
        isPresented: phoneActionIsPresented,
        titleVisibility: .visible
      ) {
        if let selectedPhoneNumber {
          Button(strings.callActionLabel) {
            self.selectedPhoneNumber = nil
            openURL(ChatLinkParser.phoneURL(for: selectedPhoneNumber))
          }
          Button(strings.messageActionLabel) {
            self.selectedPhoneNumber = nil
            openURL(ChatLinkParser.messageURL(for: selectedPhoneNumber))
          }
        }
        Button(strings.cancelActionLabel, role: .cancel) {
          selectedPhoneNumber = nil
        }
      }
  }

  private var phoneActionIsPresented: Binding<Bool> {
    Binding(
      get: { selectedPhoneNumber != nil },
      set: { isPresented in
        if !isPresented {
          selectedPhoneNumber = nil
        }
      }
    )
  }
}

enum ChatLinkTapAction: Equatable {
  case open(URL)
  case choosePhoneAction(String)
}

struct ChatDetectedLink: Equatable {
  enum Kind: String, Equatable {
    case web
    case email
    case phone
    case sms
  }

  let text: String
  let destination: URL
  let kind: Kind
  let requiresPhoneActionChoice: Bool
  fileprivate let range: Range<String.Index>
}

enum ChatLinkParser {
  private static let phoneActionScheme = "altive-chat-phone"
  private static let webPattern =
    #"(?i)(?:https?://|www\.)(?:[a-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+)"#
    + #"|(?<![:@a-z0-9._%+-])(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+"#
    + #"[a-z]{2,63}(?::[0-9]{2,5})?(?:/[a-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]*)?"#
  private static let emailPattern =
    #"(?i)(?:mailto:)?[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@"#
    + #"[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?"#
    + #"(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+"#

  static func links(in text: String) -> [ChatDetectedLink] {
    var accepted: [ChatDetectedLink] = []
    appendMatches(
      pattern: webPattern,
      in: text,
      accepted: &accepted,
      makeLink: webLink
    )
    appendMatches(
      pattern: emailPattern,
      in: text,
      accepted: &accepted,
      makeLink: emailLink
    )
    appendMatches(
      pattern: #"(?i)(?:tel:|sms:)?\+?[0-9](?:[0-9 ()-]{7,}[0-9])"#,
      in: text,
      accepted: &accepted,
      makeLink: phoneLink
    )
    return accepted.sorted { $0.range.lowerBound < $1.range.lowerBound }
  }

  static func attributedString(from text: String) -> AttributedString {
    var result = AttributedString()
    var cursor = text.startIndex
    for link in links(in: text) {
      result.append(AttributedString(String(text[cursor..<link.range.lowerBound])))
      var linkedText = AttributedString(link.text)
      linkedText.link = presentationURL(for: link)
      linkedText.underlineStyle = .single
      result.append(linkedText)
      cursor = link.range.upperBound
    }
    result.append(AttributedString(String(text[cursor...])))
    return result
  }

  static func phoneNumber(from url: URL) -> String? {
    guard url.scheme == phoneActionScheme else { return nil }
    return URLComponents(url: url, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first(where: { $0.name == "number" })?
      .value
  }

  static func action(for url: URL) -> ChatLinkTapAction {
    if let phoneNumber = phoneNumber(from: url) {
      return .choosePhoneAction(phoneNumber)
    }
    return .open(url)
  }

  static func phoneURL(for number: String) -> URL {
    URL(string: "tel:\(number)")!
  }

  static func messageURL(for number: String) -> URL {
    URL(string: "sms:\(number)")!
  }

  private static func presentationURL(for link: ChatDetectedLink) -> URL {
    guard link.requiresPhoneActionChoice else { return link.destination }
    var components = URLComponents()
    components.scheme = phoneActionScheme
    components.host = "open"
    let normalizedNumber = String(link.destination.absoluteString.dropFirst("tel:".count))
    components.queryItems = [
      URLQueryItem(name: "number", value: normalizedNumber)
    ]
    return components.url!
  }

  private static func appendMatches(
    pattern: String,
    in text: String,
    accepted: inout [ChatDetectedLink],
    makeLink: (String, Range<String.Index>) -> ChatDetectedLink?
  ) {
    guard let expression = try? NSRegularExpression(pattern: pattern) else { return }
    let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
    for match in expression.matches(in: text, range: fullRange) {
      guard var range = Range(match.range, in: text) else { continue }
      range = trimmingTrailingPunctuation(from: range, in: text)
      guard !range.isEmpty,
        !accepted.contains(where: { $0.range.overlaps(range) })
      else { continue }
      if let link = makeLink(String(text[range]), range) {
        accepted.append(link)
      }
    }
  }

  private static func webLink(
    _ matchedText: String,
    _ range: Range<String.Index>
  ) -> ChatDetectedLink? {
    let destinationText =
      matchedText.lowercased().hasPrefix("http")
      ? matchedText
      : "https://\(matchedText)"
    guard let destination = URL(string: destinationText),
      let scheme = destination.scheme?.lowercased(),
      scheme == "http" || scheme == "https",
      destination.host != nil
    else { return nil }
    return .init(
      text: matchedText,
      destination: destination,
      kind: .web,
      requiresPhoneActionChoice: false,
      range: range
    )
  }

  private static func emailLink(
    _ matchedText: String,
    _ range: Range<String.Index>
  ) -> ChatDetectedLink? {
    let destinationText =
      matchedText.lowercased().hasPrefix("mailto:")
      ? matchedText
      : "mailto:\(matchedText)"
    guard let destination = URL(string: destinationText) else { return nil }
    return .init(
      text: matchedText,
      destination: destination,
      kind: .email,
      requiresPhoneActionChoice: false,
      range: range
    )
  }

  private static func phoneLink(
    _ matchedText: String,
    _ range: Range<String.Index>
  ) -> ChatDetectedLink? {
    let lowercased = matchedText.lowercased()
    let explicitScheme = lowercased.hasPrefix("tel:") || lowercased.hasPrefix("sms:")
    let numberText = explicitScheme ? String(matchedText.dropFirst(4)) : matchedText
    let number = normalizedPhoneNumber(numberText)
    let digitCount = number.filter(\.isNumber).count
    guard (9...15).contains(digitCount) else { return nil }
    let kind: ChatDetectedLink.Kind = lowercased.hasPrefix("sms:") ? .sms : .phone
    let scheme = kind == .sms ? "sms" : "tel"
    guard let destination = URL(string: "\(scheme):\(number)") else { return nil }
    return .init(
      text: matchedText,
      destination: destination,
      kind: kind,
      requiresPhoneActionChoice: !explicitScheme,
      range: range
    )
  }

  private static func normalizedPhoneNumber(_ text: String) -> String {
    text.enumerated().compactMap { offset, character in
      if character.isNumber || (character == "+" && offset == 0) {
        character
      } else {
        nil
      }
    }.reduce(into: "") { $0.append($1) }
  }

  private static func trimmingTrailingPunctuation(
    from range: Range<String.Index>,
    in text: String
  ) -> Range<String.Index> {
    let punctuation = CharacterSet(charactersIn: ".,!?;:、。！？；：)]}）》」』】")
    var upperBound = range.upperBound
    while upperBound > range.lowerBound {
      let previousIndex = text.index(before: upperBound)
      guard String(text[previousIndex]).rangeOfCharacter(from: punctuation) != nil else { break }
      upperBound = previousIndex
    }
    return range.lowerBound..<upperBound
  }
}
