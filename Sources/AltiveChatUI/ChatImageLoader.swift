import Foundation

/// ローカルまたはリモートのチャット画像を読み込む処理。
public struct ChatImageLoader: Sendable {
  private let loadData: @Sendable (ChatImageResource) async throws -> Data

  /// 任意の画像読み込み処理を作成する。
  public init(loadData: @escaping @Sendable (ChatImageResource) async throws -> Data) {
    self.loadData = loadData
  }

  /// 指定した画像のバイト列を返す。
  public func data(for resource: ChatImageResource) async throws -> Data {
    try await loadData(resource)
  }

  /// ローカルファイルはファイルシステム、リモート画像は `URLSession` で読み込む。
  public static let standard = ChatImageLoader { resource in
    switch resource {
    case .localFile(let url):
      return try await Task.detached(priority: .userInitiated) {
        try Data(contentsOf: url, options: [.mappedIfSafe])
      }.value
    case .remote(let url):
      let (data, response) = try await URLSession.shared.data(from: url)
      if let response = response as? HTTPURLResponse,
        !(200..<300).contains(response.statusCode)
      {
        throw URLError(.badServerResponse)
      }
      return data
    }
  }
}
