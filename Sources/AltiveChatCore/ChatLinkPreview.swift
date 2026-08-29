import Foundation

/// リンクプレビュー画像をアプリ側のloaderへ渡す参照。
public struct ChatLinkPreviewImage: Hashable, Sendable {
  /// アプリ側だけが解釈する画像参照。
  public let resource: String

  /// 画像のピクセル幅。
  public let pixelWidth: Int

  /// 画像のピクセル高さ。
  public let pixelHeight: Int

  /// 有効な画像参照と寸法から表示値を作成する。
  public init?(resource: String, pixelWidth: Int, pixelHeight: Int) {
    let normalizedResource = resource.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedResource.isEmpty, pixelWidth > 0, pixelHeight > 0 else { return nil }
    self.resource = normalizedResource
    self.pixelWidth = pixelWidth
    self.pixelHeight = pixelHeight
  }
}

/// アプリ側で解決済みのWebリンクプレビュー表示値。
public struct ChatLinkPreview: Hashable, Sendable {
  /// カード操作時に開くHTTP(S) URL。
  public let sourceURL: URL

  /// 1〜200文字のタイトル。
  public let title: String

  /// 最大500文字の説明。
  public let description: String?

  /// 最大100文字のサイト名。
  public let siteName: String?

  /// アプリ側のloaderで読み込む任意の画像。
  public let image: ChatLinkPreviewImage?

  /// 検証済みの表示値を作成する。
  ///
  /// タイトルが空、URLがHTTP(S)以外、または文字数上限を超える場合は `nil` を返す。
  public init?(
    sourceURL: URL,
    title: String,
    description: String? = nil,
    siteName: String? = nil,
    image: ChatLinkPreviewImage? = nil
  ) {
    guard let scheme = sourceURL.scheme?.lowercased(),
      scheme == "http" || scheme == "https",
      sourceURL.host != nil
    else { return nil }

    let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedDescription = Self.normalizedOptional(description)
    let normalizedSiteName = Self.normalizedOptional(siteName)
    guard !normalizedTitle.isEmpty,
      normalizedTitle.count <= 200,
      normalizedDescription?.count ?? 0 <= 500,
      normalizedSiteName?.count ?? 0 <= 100
    else { return nil }

    self.sourceURL = sourceURL
    self.title = normalizedTitle
    self.description = normalizedDescription
    self.siteName = normalizedSiteName
    self.image = image
  }

  private static func normalizedOptional(_ value: String?) -> String? {
    guard let value else { return nil }
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return normalized.isEmpty ? nil : normalized
  }
}

/// テキスト内で最初に現れるWeb URLを選ぶparser。
public enum ChatWebURLParser {
  private static let pattern =
    #"(?i)(?<![a-z0-9+.\-:])https?://[a-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+"#
    + #"|(?<![:@a-z0-9._%+\-])(?<!://)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+"#
    + #"[a-z]{2,63}(?::[0-9]{2,5})?(?:/[a-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]*)?"#

  /// テキスト内で最初に現れるHTTP(S) URLを返す。
  public static func firstURL(in text: String) -> URL? {
    guard let expression = try? NSRegularExpression(pattern: pattern) else { return nil }
    let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
    for match in expression.matches(in: text, range: fullRange) {
      guard var range = Range(match.range, in: text) else { continue }
      while !range.isEmpty {
        let lastIndex = text.index(before: range.upperBound)
        guard trailingPunctuation.contains(text[lastIndex]) else { break }
        range = range.lowerBound..<lastIndex
      }
      guard !range.isEmpty else { continue }
      let matchedText = String(text[range])
      let candidate =
        matchedText.lowercased().hasPrefix("http")
        ? matchedText
        : "https://\(matchedText)"
      guard let url = URL(string: candidate), url.host != nil,
        let normalizedURL = normalized(url)
      else { continue }
      return normalizedURL
    }
    return nil
  }

  private static func normalized(_ url: URL) -> URL? {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let scheme = components.scheme?.lowercased(), scheme == "http" || scheme == "https",
      let host = components.host?.lowercased(), !host.isEmpty
    else { return nil }
    components.scheme = scheme
    components.host = host
    components.fragment = nil
    if (scheme == "http" && components.port == 80)
      || (scheme == "https" && components.port == 443)
    {
      components.port = nil
    }
    return components.url
  }

  private static let trailingPunctuation = ".,!?;:、。！？；：)]}>）］｝〉》」』】"
}
